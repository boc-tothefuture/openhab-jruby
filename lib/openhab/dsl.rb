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
# Main openHAB Module
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
    [Core::Actions, Core::ScriptHandling, Rules::Terse].each do |mod|
      # make these available both as regular and class methods
      include mod
      singleton_class.include mod
      public_class_method(*mod.private_instance_methods)
    end

    module_function

    # @!group Rule Creation

    # (see Rules::Builder#rule)
    def rule(name = nil, **kwargs, &block)
      rules.build { rule(name, **kwargs, &block) }
    end

    # (see Rules::Builder#script)
    def script(name = nil, id: nil, **kwargs, &block)
      rules.build { script(name, id: id, **kwargs, &block) }
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
    # @yieldparam [Item] item The linked item.
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

      ThreadLocal.thread_local(openhab_rule_type: "profile", openhab_rule_uid: id) do
        Core::ProfileFactory.instance.register(uid, block)
      end
    end

    # @!group Object Access

    #
    # (see Core::ValueCache)
    #
    # @return [Core::ValueCache] the cache shared among all scripts and UI rules in all languages.
    #
    # @see Core::ValueCache ValueCache
    #
    # @since openHAB 3.4.0
    #
    def shared_cache
      $sharedCache
    end

    #
    # Fetches all rules from the rule registry.
    #
    # @return [Core::Rules::Registry]
    #
    def rules
      Core::Rules::Registry.instance
    end

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
    #     on_load
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
    # Get all things known to openHAB
    #
    # @return [Core::Things::Registry] all Thing objects known to openHAB
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
    # Provides access to timers created by {after after}
    #
    # @return [TimerManager]
    def timers
      TimerManager.instance
    end

    # @!group Utilities

    #
    # Create a timer and execute the supplied block after the specified duration
    #
    # ### Reentrant Timers
    #
    # Timers with an id are reentrant by id. Reentrant means that when the same id is encountered,
    # the timer is rescheduled rather than creating a second new timer. Note that the timer will
    # execute the block provided in the latest call.
    #
    # This removes the need for the usual boilerplate code to manually keep track of timer objects.
    #
    # Timers with `id` can be managed with the built-in {timers} object.
    #
    # When a timer is cancelled, it will be removed from the object.
    #
    # Be sure that your ids are unique. For example, if you're using {Item items} as your
    # ids, you either need to be sure you don't use the same item for multiple logical contexts,
    # or you need to make your id more specific, by doing something like embedding the item in
    # array with a symbol of the timer's purpose, like `[:vacancy, item]`. But also note that
    # assuming default settings, every Ruby file (for file-based rules) or UI rule gets its
    # own instance of the timers object, so you don't need to worry about collisions among
    # different files.
    #
    # @see timers
    # @see Rules::BuilderDSL#changed
    # @see Items::TimedCommand
    #
    # @param [java.time.temporal.TemporalAmount, #to_zoned_date_time, Proc] duration
    #   Duration after which to execute the block
    # @param [Object] id ID to associate with timer. The timer can be managed via {timers}.
    # @param [true,false] reschedule Reschedule the timer if it already exists.
    # @yield Block to execute when the timer is elapsed.
    # @yieldparam [Core::Timer] timer
    #
    # @return [Core::Timer] if `reschedule` is false, the existing timer.
    #   Otherwise the new timer.
    #
    # @example Create a simple timer
    #   after 5.seconds do
    #     logger.info("Timer Fired")
    #   end
    #
    # @example Timers delegate methods to openHAB timer objects
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
    # @example Reentrant timers will automatically reschedule if the same id is encountered again
    #   rule "Turn off closet light after 10 minutes" do
    #     changed ClosetLights.members, to: ON
    #     triggered do |item|
    #       after 10.minutes, id: item do
    #         item.ensure.off
    #       end
    #     end
    #   end
    #
    # @example Timers with id can be managed through the built-in `timers` object
    #   after 1.minute, id: :foo do
    #     logger.info("managed timer has fired")
    #   end
    #
    #   timers.cancel(:foo)
    #
    #   if timers.include?(:foo)
    #     logger.info("The timer :foo is not active")
    #   end
    #
    # @example Only create a new timer if it isn't already scheduled
    #   after(1.minute, id: :foo, reschedule: false) do
    #     logger.info("Timer fired")
    #   end
    #
    # @example Reentrant timers will execute the block from the most recent call
    #   # In the following example, if Item1 received a command, followed by Item2,
    #   # the timer will execute the block referring to Item2.
    #   rule "Execute The Most Recent Block" do
    #     received_command Item1, Item2
    #     run do |event|
    #       after(10.minutes, id: :common_timer) do
    #         logger.info "The latest command was received from #{event.item}"
    #       end
    #     end
    #   end
    #
    def after(duration, id: nil, reschedule: true, &block)
      raise ArgumentError, "Block is required" unless block

      # Carry rule name to timer
      thread_locals = ThreadLocal.persist
      timers.create(duration, id: id, reschedule: reschedule, thread_locals: thread_locals, block: block)
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
    # @see CoreExt::Between#between? #between?
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
    # current state of each item. It is implemented by calling openHAB's
    # [events.storeStates()](https://www.openhab.org/docs/configuration/actions.html#event-bus-actions).
    #
    # @param [Item] items Items to store states of.
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
    # of previous calls unless they are for the same dimension.
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

    #
    # Sets the implicit provider(s) for operations inside the block.
    #
    # @param (see #provider!)
    # @yield [] The block will be executed in the context of the specified unit(s).
    # @return [Object] the result of the block
    #
    # @example
    #   provider(metadata: :persistent) do
    #     Switch1.metadata[:last_status_from_service] = status
    #   end
    #
    #   provider!(metadata: { last_status_from_service: :persistent }, Switch2: :persistent)
    #   Switch1.metadata[:last_status_from_service] = status # this will persist in JSONDB
    #   Switch1.metadata[:homekit] = "Lightbulb" # this will be removed when the script is deleted
    #   Switch2.metadata[:homekit] = "Lightbulb" # this will persist in JSONDB
    #
    # @see provider!
    # @see OpenHAB::Core::Provider.current Provider.current for how the current provider is calculated
    #
    def provider(*args, **kwargs)
      raise ArgumentError, "You must give a block to set the provider for the duration of" unless block_given?

      begin
        old_providers = provider!(*args, **kwargs)
        yield
      ensure
        Thread.current[:openhab_providers] = old_providers
      end
    end

    #
    # Permanently set the implicit provider(s) for this thread.
    #
    # @note This method is only intended for use at the top level of rule
    #   scripts. If it's used within library methods, or hap-hazardly within
    #   rules, things can get very confusing because the prior state won't be
    #   properly restored.
    #
    # {provider!} calls are cumulative - additional calls will not erase the effects
    # of previous calls unless they are for the same provider type.
    #
    # @overload provider!(things: nil, items: nil, metadata: nil, links: nil, **metadata_items)
    #
    # @param [Core::Provider, org.openhab.core.common.registry.ManagedProvider, :persistent, :transient, Proc] providers
    #   An explicit provider to use. If it's a {Core::Provider}, the type will be inferred automatically.
    #   Otherwise it's applied to all types.
    # @param [Hash] providers_by_type
    #     A list of providers by type. Type can be `:items`, `:metadata`, `:things`, `:links`,
    #     an {Item} applying the provider to all metadata on that item, or a String or Symbol
    #     applying the provider to all metadata of that namespace.
    #
    #     The provider can be a {org.openhab.core.common.registry.Provider Provider}, `:persistent`,
    #     `:transient`, or a Proc returning one of those types. When the Proc is called for metadata
    #     elements, the {Core::Items::Metadata::Hash} will be passed as an argument. Therefore it's
    #     recommended that you use a Proc, not a Lambda, for permissive argument matching.
    #
    # @return [void]
    #
    # @see provider
    # @see OpenHAB::Core::Provider.current Provider.current for how the current provider is calculated
    #
    def provider!(*providers, **providers_by_type)
      thread_providers = Thread.current[:openhab_providers] ||= {}
      old_providers = thread_providers.dup

      providers.each do |provider|
        case provider
        when Core::Provider
          thread_providers[provider.class.type] = provider
        when org.openhab.core.common.registry.ManagedProvider
          type = provider.type
          unless type
            raise ArgumentError, "#{provider.inspect} is for objects which are not supported by openhab-jrubyscripting"
          end

          thread_providers[type] = provider
        when Proc,
          :transient,
          :persistent
          Core::Provider::KNOWN_TYPES.each do |known_type|
            thread_providers[known_type] = provider
          end
        when Hash
          # non-symbols can't be used as kwargs, so Item keys show up as a separate hash here
          # just merge it in, and allow it to be handled below
          providers_by_type.merge!(provider)
        else
          raise ArgumentError, "#{provider.inspect} is not a valid provider"
        end
      end

      providers_by_type.each do |type, provider|
        case provider
        when Proc,
          org.openhab.core.common.registry.ManagedProvider,
          :transient,
          :persistent,
          nil
          nil
        else
          raise ArgumentError, "#{provider.inspect} is not a valid provider"
        end

        case type
        when :items, :metadata, :things, :links
          if provider.is_a?(org.openhab.core.common.registry.ManagedProvider) && provider.type != type
            raise ArgumentError, "#{provider.inspect} is not a provider for #{type}"
          end

          thread_providers[type] = provider
        when Symbol, String
          (thread_providers[:metadata_namespaces] ||= {})[type.to_s] = provider
        when Item
          (thread_providers[:metadata_items] ||= {})[type.name] = provider
        else
          raise ArgumentError, "#{type.inspect} is not provider type"
        end
      end

      old_providers
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

# import Items classes into global namespace
OpenHAB::Core::Items.import_into_global_namespace

# Extend `main` with DSL methods
singleton_class.include(OpenHAB::DSL)

logger.debug "openHAB JRuby Scripting Library Version #{OpenHAB::DSL::VERSION} Loaded"
