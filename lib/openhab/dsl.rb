# frozen_string_literal: true

require "java"
require "method_source"

require "bundler/inline"

require_relative "log"
require_relative "osgi"
require_relative "core"

Dir[File.expand_path("dsl/**/*.rb", __dir__)].sort.each do |f|
  require f
end

require_relative "core_ext"

#
# Main OpenHAB Module
#
module OpenHAB
  #
  # The main DSL available to rules.
  #
  # Methods on this module are extended onto `main`, the top level `self` in
  # any file. You can also access them as class methods on the module for use
  # inside of other classes, or include the module.
  #
  module DSL
    # include this before Core::Actions so that Core::Action's method_missing
    # takes priority
    include Core::EntityLookup
    [Core::Actions, Rules::Terse, ScriptHandling].each do |mod|
      # make these available both as regular and class methods
      include mod
      singleton_class.include mod
      public_class_method(*mod.private_instance_methods)
    end

    module_function

    # @!group Rule Creation

    #
    # Create a new rule
    #
    # @param [String] name The rule name
    # @yield Block executed in context of a {Rules::Builder}
    # @yieldparam [Rules::Builder] rule
    #   Optional parameter to access the rule configuration from within execution blocks and guards.
    # @return [org.openhab.core.automation.Rule] The OpenHAB Rule object
    #
    # @see OpenHAB::DSL::Rules::Builder Rule builder for details on rule triggers, guards and execution blocks
    # @see Rules::Terse Terse Rules
    #
    # @example
    #   require "openhab/dsl"
    #
    #   rule "name" do
    #     <zero or more triggers>
    #     <zero or more execution blocks>
    #     <zero or more guards>
    #   end
    #
    def rule(name = nil, id: nil, script: nil, binding: nil, &block)
      raise ArgumentError, "Block is required" unless block

      id ||= Rules::NameInference.infer_rule_id_from_name(name) if name
      id ||= Rules::NameInference.infer_rule_id_from_block(block)
      script ||= block.source rescue nil # rubocop:disable Style/RescueModifier

      builder = nil

      ThreadLocal.thread_local(openhab_rule_uid: id) do
        builder = Rules::Builder.new(binding || block.binding)
        builder.uid(id)
        builder.instance_exec(&block)
        builder.guard = Rules::Guard.new(run_context: builder.caller, only_if: builder.only_if,
                                         not_if: builder.not_if)

        name ||= Rules::NameInference.infer_rule_name(builder)
        name ||= id

        builder.name(name)
        logger.trace { builder.inspect }
        builder.build(script)
      rescue Exception => e
        builder.send(:logger).log_exception(e)
      end
    end

    #
    # Create a new script
    #
    # A script is a rule with no triggers. It can be called by various other actions,
    # such as the Run Rules action, or the script channel profile.
    #
    # Input variables are sent as keyword arguments to the block.
    # The result of the block may be significant (like for the script channel profile).
    #
    # @param [String] id The script's ID
    # @param [String] name A descriptive name
    # @yield [] Block executed when the script is executed.
    #
    def script(name = nil, id: nil, script: nil, &block)
      raise ArgumentError, "Block is required" unless block

      id ||= Rules::NameInference.infer_rule_id_from_name(name) if name
      id ||= Rules::NameInference.infer_rule_id_from_block(block)
      name ||= id
      script ||= block.source rescue nil # rubocop:disable Style/RescueModifier

      builder = nil
      ThreadLocal.thread_local(openhab_rule_uid: id) do
        builder = Rules::Builder.new(block.binding)
        builder.uid(id)
        builder.tags(["Script"])
        builder.name(name)
        builder.script(&block)
        logger.trace { builder.inspect }
        builder.build(script)
      end
    rescue Exception => e
      builder.send(:logger).log_exception(e)
    end

    # @!group Rule Support

    #
    # Defines a new profile that can be applied to item channel links.
    #
    # @param [String, Symbol] id The id for the profile.
    # @yield [event, command: nil, state: nil, link:, item:, channel_uid:, configuration:, context:]
    #   All keyword params are optional. Any that aren't defined won't be passed.
    # @yieldparam [Core::Things::ProfileCallback] callback
    #   The callback to be used to customize the action taken.
    # @yieldparam [:command_from_item, :state_from_item, :command_from_handler, :state_from_handler] event
    #   The event that needs to be processed.
    # @yieldparam [Command, nil] command
    #   The command being sent for `:command_from_item` and `:command_from_handler` events.
    # @yieldparam [State, nil] state
    #   The state being sent for `:state_from_item` and `:state_from_handler` events.
    # @yieldparam [Core::Things::ItemChannelLink] link
    #   The link between the item and the channel, including its configuration.
    # @yieldparam [GenericItem] item The linked item.
    # @yieldparam [Core::Things::ChannelUID] channel_uid The linked channel.
    # @yieldparam [Hash] configuration The profile configuration.
    # @yieldparam [org.openhab.core.thing.profiles.ProfileContext] context The profile context.
    # @yieldreturn [Boolean] Return true from the block in order to have default processing.
    # @return [void]
    #
    # @see org.openhab.thing.Profile
    # @see org.openhab.thing.StateProfile
    #
    # @example
    #   profile(:veto_closing_shades) do |event, item:, command: nil|
    #     next false if command&.down?
    #
    #     true
    #   end
    #
    #   items.build do
    #     rollershutter_item "MyShade" do
    #       channel "thing:rollershutter", profile: "ruby:veto_closing_shades"
    #     end
    #   end
    #   # can also be referenced from an `.items` file:
    #   # Rollershutter MyShade { channel="thing:rollershutter"[profile="ruby:veto_closing_shades"] }
    #
    def profile(id, &block)
      raise ArgumentError, "Block is required" unless block

      uid = org.openhab.core.thing.profiles.ProfileTypeUID.new("ruby", id)

      Core::ProfileFactory.instance.register(uid, block)
    end

    #
    # Remove a rule
    #
    # @param [String, org.openhab.core.automation.Rule] uid The rule UID or the Rule object to remove.
    # @return [void]
    #
    # @example
    #   my_rule = rule do
    #     every :day
    #     run { nil }
    #   end
    #
    #   remove_rule(my_rule)
    #
    def remove_rule(uid)
      uid = uid.uid if uid.respond_to?(:uid)
      automation_rule = Rules.script_rules.delete(uid)
      raise "Rule #{uid} doesn't exist to remove" unless automation_rule

      automation_rule.cleanup
      # automation_manager doesn't have a remove method, so just have to
      # remove it directly from the provider
      Rules.scripted_rule_provider.remove_rule(uid)
    end

    #
    # Manually trigger a rule by ID
    #
    # @param [String] uid The rule ID
    # @param [Object, nil] event The event to pass to the rule's execution blocks.
    # @return [void]
    #
    def trigger_rule(uid, event = nil)
      Rules.script_rules.fetch(uid).execute(nil, { "event" => event })
    end

    # @!group Object Access

    #
    # Fetches all items from the item registry
    #
    # @return [Core::Items::Registry]
    #
    # The examples all assume the following items exist.
    #
    # ```xtend
    # Dimmer DimmerTest "Test Dimmer"
    # Switch SwitchTest "Test Switch"
    # ```
    #
    # @example
    #   logger.info("Item Count: #{items.count}")  # Item Count: 2
    #   logger.info("Items: #{items.map(&:label).sort.join(', ')}")  # Items: Test Dimmer, Test Switch'
    #   logger.info("DimmerTest exists? #{items.key?('DimmerTest')}") # DimmerTest exists? true
    #   logger.info("StringTest exists? #{items.key?('StringTest')}") # StringTest exists? false
    #
    # @example
    #   rule 'Use dynamic item lookup to increase related dimmer brightness when switch is turned on' do
    #     changed SwitchTest, to: ON
    #     triggered { |item| items[item.name.gsub('Switch','Dimmer')].brighten(10) }
    #   end
    #
    # @example
    #   rule 'search for a suitable item' do
    #     on_start
    #     triggered do
    #       # Send ON to DimmerTest if it exists, otherwise send it to SwitchTest
    #       (items['DimmerTest'] || items['SwitchTest'])&.on
    #     end
    #   end
    #
    def items
      Core::Items::Registry.instance
    end

    #
    # Get all things known to OpenHAB
    #
    # @return [Core::Things::Registry] all Thing objects known to OpenHAB
    #
    # @example
    #   things.each { |thing| logger.info("Thing: #{thing.uid}")}
    #   logger.info("Thing: #{things['astro:sun:home'].uid}")
    #   homie_things = things.select { |t| t.thing_type_uid == "mqtt:homie300" }
    #   zwave_things = things.select { |t| t.binding_id == "zwave" }
    #   homeseer_dimmers = zwave_things.select { |t| t.thing_type_uid.id == "homeseer_hswd200_00_000" }
    #   things['zwave:device:512:node90'].uid.bridge_ids # => ["512"]
    #   things['mqtt:topic:4'].uid.bridge_ids # => []
    #
    def things
      Core::Things::Registry.instance
    end

    #
    # Provides access to the hash for mapping timer ids created by {after}
    # to the set of active timers associated with that id
    #
    # @return [Hash] hash of user specified ids to {TimerSet}
    def timers
      TimerManager.instance.timers_by_id
    end

    # @!group Utilities

    #
    # Create a timer and execute the supplied block after the specified duration
    #
    # ### Reentrant Timer
    #
    # Timers with an id are reentrant, by id and block. Reentrant means that when the same id and block are encountered,
    # the timer is rescheduled rather than creating a second new timer.
    #
    # This removes the need for the usual boilerplate code to manually keep track of timer objects.
    #
    # ### Managing Timers with `id`
    #
    # Timers with `id` can be managed with the built-in {timers} hash. Multiple timer blocks can share
    # the same `id`, which is why `timers[id]` returns a {TimerSet} object. It is a descendant of `Set`
    # and it contains a set of timers associated with that id.
    #
    # When a timer is cancelled, it will be removed from the set. Once the set is empty, it will be removed
    # from `timers[]` hash and `timers[id]` will return nil.
    #
    # @see timers
    # @see Rules::Builder#changed
    # @see Items::TimedCommand
    #
    # @param [java.time.temporal.TemporalAmount, #to_zoned_date_time, Proc] duration after which to execute the block
    # @param [Object] id to associate with timer. The timer can be accessed with the {timers} hash.
    # @param [Block] block to execute, block is passed a Timer object
    # @yieldparam [Core::Timer] timer
    #
    # @return [Core::Timer]
    #
    # @example Create a simple timer
    #   after 5.seconds do
    #     logger.info("Timer Fired")
    #   end
    #
    # @example Timers delegate methods to OpenHAB timer objects
    #   after 1.second do |timer|
    #     logger.info("Timer is active? #{timer.active?}")
    #   end
    #
    # @example Timers can be rescheduled to run again, waiting the original duration
    #   after 3.seconds do |timer|
    #     logger.info("Timer Fired")
    #     timer.reschedule
    #   end
    #
    # @example Timers can be rescheduled for different durations
    #   after 3.seconds do |timer|
    #     logger.info("Timer Fired")
    #     timer.reschedule 5.seconds
    #   end
    #
    # @example Timers can be manipulated through the returned object
    #   mytimer = after 1.minute do
    #     logger.info("It has been 1 minute")
    #   end
    #
    #   mytimer.cancel
    #
    # @example Reentrant timers will automatically reschedule if the same block is encountered again
    #   rule "Turn off closet light after 10 minutes" do
    #     changed ClosetLights.members, to: ON
    #     triggered do |item|
    #       after 10.minutes, id: item do
    #         item.ensure.off
    #       end
    #     end
    #   end
    #
    # @example Timers with id can be managed through the built-in `timers[]` hash
    #   after 1.minute, :id => :foo do
    #     logger.info("managed timer has fired")
    #   end
    #
    #   timers[:foo]&.cancel
    #
    #   if !timers[:foo]
    #     logger.info("The timer :foo is not active")
    #   end
    #
    def after(duration, id: nil, &block)
      raise ArgumentError, "Block is required" unless block

      # Carry rule name to timer
      thread_locals = ThreadLocal.persist
      DSL::TimerManager.instance.create(duration, id: id, thread_locals: thread_locals, block: block)
    end

    #
    # Convert a string based range into a range of LocalTime, LocalDate, MonthDay, or ZonedDateTime
    # depending on the format of the string.
    #
    # @return [Range] converted range object
    #
    # @example Range#cover?
    #   logger.info("Within month-day range") if between('02-20'..'06-01').cover?(MonthDay.now)
    #
    # @example Use in a Case
    #   case MonthDay.now
    #   when between('01-01'..'03-31')
    #     logger.info("First quarter")
    #   when between('04-01'..'06-30')
    #    logger.info("Second quarter")
    #   end
    #
    # @example Create a time range
    #   between('7am'..'12pm').cover?(LocalTime.now)
    #
    def between(range)
      raise ArgumentError, "Supplied object must be a range" unless range.is_a?(Range)

      start = try_parse_time_like(range.begin)
      finish = try_parse_time_like(range.end)
      Range.new(start, finish, range.exclude_end?)
    end

    #
    # Store states of supplied items
    #
    # Takes one or more items and returns a map `{Item => State}` with the
    # current state of each item. It is implemented by calling OpenHAB's
    # [events.storeStates()](https://www.openhab.org/docs/configuration/actions.html#event-bus-actions).
    #
    # @param [GenericItem] items Items to store states of.
    #
    # @return [Core::Items::StateStorage] item states
    #
    # @example
    #   states = store_states Item1, Item2
    #   ...
    #   states.restore
    #
    # @example With a block
    #   store_states Item1, Item2 do
    #     ...
    #   end # the states will be restored here
    #
    def store_states(*items)
      items = items.flatten.map do |item|
        item.respond_to?(:__getobj__) ? item.__getobj__ : item
      end
      states = Core::Items::StateStorage.from_items(*items)
      if block_given?
        yield
        states.restore
      end
      states
    end

    #
    # @!group Block Modifiers
    #   These methods allow certain operations to be grouped inside the given block
    #   to reduce repetitions
    #

    #
    # Global method that takes a block and for the duration of the block
    # all commands sent will check if the item is in the command's state
    # before sending the command.
    #
    # @yield
    # @return [Object] The result of the block.
    #
    # @example Turn on several switches only if they're not already on
    #   ensure_states do
    #     Switch1.on
    #     Switch2.on
    #   end
    #
    # @example
    #   # VirtualSwitch is in state `ON`
    #   ensure_states do
    #     VirtualSwitch << ON       # No command will be sent
    #     VirtualSwitch.update(ON)  # No update will be posted
    #     VirtualSwitch << OFF      # Off command will be sent
    #     VirtualSwitch.update(OFF) # No update will be posted
    #   end
    #
    # @example
    #   ensure_states do
    #     rule 'Items in an execution block will have ensure_states applied to them' do
    #       changed VirtualSwitch
    #       run do
    #         VirtualSwitch.on
    #         VirtualSwitch2.on
    #       end
    #     end
    #   end
    #
    # @example
    #   rule 'ensure_states must be in an execution block' do
    #     changed VirtualSwitch
    #     run do
    #        ensure_states do
    #           VirtualSwitch.on
    #           VirtualSwitch2.on
    #        end
    #     end
    #   end
    #
    def ensure_states
      old = Thread.current[:openhab_ensure_states]
      Thread.current[:openhab_ensure_states] = true
      yield
    ensure
      Thread.current[:openhab_ensure_states] = old
    end

    #
    # Sets a thread local variable to set the default persistence service
    # for method calls inside the block
    #
    # @example
    #   persistence(:influxdb) do
    #     Item1.persist
    #     Item1.changed_since(1.hour)
    #     Item1.average_since(12.hours)
    #   end
    #
    # @see OpenHAB::Core::Items::Persistence
    #
    # @param [Object] service service either as a String or a Symbol
    # @yield [] Block executed in context of the supplied persistence service
    # @return [Object] The return value from the block.
    #
    def persistence(service)
      old = Thread.current[:openhab_persistence_service]
      Thread.current[:openhab_persistence_service] = service
      yield
    ensure
      Thread.current[:openhab_persistence_service] = old
    end

    #
    # Sets the implicit unit(s) for operations inside the block.
    #
    # @yield
    #
    # @overload unit(*units)
    #   Sets the implicit unit(s) for this thread such that classes
    #   operating inside the block can perform automatic conversions to the
    #   supplied unit for {QuantityType}.
    #
    #   To facilitate conversion of multiple dimensioned and dimensionless
    #   numbers the unit block may be used. The unit block attempts to do the
    #   _right thing_ based on the mix of dimensioned and dimensionless items
    #   within the block. Specifically all dimensionless items are converted to
    #   the supplied unit, except when they are used for multiplication or
    #   division.
    #
    #   @param [String, javax.measure.Unit] units
    #     Unit or String representing unit
    #   @yield [] The block will be executed in the context of the specified unit(s).
    #   @return [Object] the result of the block
    #
    #   @example Arithmetic Operations Between QuantityType and Numeric
    #     # Number:Temperature NumberC = 23 °C
    #     # Number:Temperature NumberF = 70 °F
    #     # Number Dimensionless = 2
    #     unit('°F') { NumberC.state - NumberF.state < 4 }                                      # => true
    #     unit('°F') { NumberC.state - 24 | '°C' < 4 }                                          # => true
    #     unit('°F') { (24 | '°C') - NumberC.state < 4 }                                        # => true
    #     unit('°C') { NumberF.state - 20 < 2 }                                                 # => true
    #     unit('°C') { NumberF.state - Dimensionless.state }                                    # => 19.11 °C
    #     unit('°C') { NumberF.state - Dimensionless.state < 20 }                               # => true
    #     unit('°C') { Dimensionless.state + NumberC.state == 25 }                              # => true
    #     unit('°C') { 2 + NumberC.state == 25 }                                                # => true
    #     unit('°C') { Dimensionless.state * NumberC.state == 46 }                              # => true
    #     unit('°C') { 2 * NumberC.state == 46 }                                                # => true
    #     unit('°C') { ( (2 * (NumberF.state + NumberC.state) ) / Dimensionless.state ) < 45 }  # => true
    #     unit('°C') { [NumberC.state, NumberF.state, Dimensionless.state].min }                # => 2
    #
    #   @example Commands and Updates inside a unit block
    #     unit('°F') { NumberC << 32 }; NumberC.state                                           # => 0 °C
    #     # Equivalent to
    #     NumberC << "32 °F"
    #     # or
    #     NumberC << 32 | "°F"
    #
    #   @example Specifying Multiple Units
    #     unit("°C", "kW") do
    #       TemperatureItem.update("50 °F")
    #       TemperatureItem.state < 20          # => true. TemperatureItem.state < 20 °C
    #       PowerUsage.update("3000 W")
    #       PowerUsage.state < 10               # => true. PowerUsage.state < 10 kW
    #     end
    #
    # @overload unit(dimension)
    #   @param [javax.measure.Dimension] dimension The dimension to fetch the unit for.
    #   @return [javax.measure.Unit] The current unit for the thread of the specified dimensions
    #
    #   @example
    #     unit(SIUnits::METRE.dimension) # => ImperialUnits::FOOT
    #
    def unit(*units)
      if units.length == 1 && units.first.is_a?(javax.measure.Dimension)
        return Thread.current[:openhab_units]&.[](units.first)
      end

      raise ArgumentError, "You must give a block to set the unit for the duration of" unless block_given?

      begin
        old_units = unit!(*units)
        yield
      ensure
        Thread.current[:openhab_units] = old_units
      end
    end

    #
    # Permanently sets the implicit unit(s) for this thread
    #
    # @note This method is only intended for use at the top level of rule
    #   scripts. If it's used within library methods, or hap-hazardly within
    #   rules, things can get very confusing because the prior state won't be
    #   properly restored.
    #
    # {unit!} calls are cumulative - additional calls will not erase the effects
    # previous calls unless they are for the same dimension.
    #
    # @return [Hash<javax.measure.Dimension=>javax.measure.Unit>]
    #   the prior unit configuration
    #
    # @overload unit!(*units)
    #   @param [String, javax.measure.Unit] units
    #     Unit or String representing unit.
    #
    #   @example Set several defaults at once
    #     unit!("°F", "ft", "lbs")
    #     (50 | "°F") == 50 # => true
    #
    #   @example Calls are cumulative
    #     unit!("°F")
    #     unit!("ft")
    #     (50 | "°F") == 50 # => true
    #     (2 | "yd") == 6 # => true
    #
    #   @example Subsequent calls override the same dimension from previous calls
    #     unit!("yd")
    #     unit!("ft")
    #     (2 | "yd") == 6 # => true
    #
    # @overload unit!
    #   Clear all unit settings
    #
    #   @example Clear all unit settings
    #     unit!("ft")
    #     unit!
    #     (2 | "yd") == 6 # => false
    #
    def unit!(*units)
      units = units.each_with_object({}) do |unit, r|
        unit = org.openhab.core.types.util.UnitUtils.parse_unit(unit) if unit.is_a?(String)
        r[unit.dimension] = unit
      end

      old_units = Thread.current[:openhab_units] || {}
      Thread.current[:openhab_units] = units.empty? ? {} : old_units.merge(units)
      old_units
    end

    # @!visibility private
    def try_parse_time_like(string)
      return string unless string.is_a?(String)

      exception = nil
      [java.time.LocalTime, java.time.LocalDate, java.time.MonthDay, java.time.ZonedDateTime].each do |klass|
        return klass.parse(string)
      rescue ArgumentError => e
        exception ||= e
        next
      end

      raise exception
    end
  end
end

OpenHAB::Core.wait_till_openhab_ready
OpenHAB::Core.add_rubylib_to_load_path

# import Items classes into global namespace
OpenHAB::Core::Items.import_into_global_namespace

# Extend `main` with DSL methods
singleton_class.include(OpenHAB::DSL)

OpenHAB::DSL.send(:logger).debug "OpenHAB JRuby Scripting Library Version #{OpenHAB::DSL::VERSION} Loaded"
