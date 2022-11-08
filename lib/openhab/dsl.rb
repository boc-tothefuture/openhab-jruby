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

module OpenHAB
  #
  # The main DSL available to rules.
  #
  # Methods on this module are extended onto `main`, the top level `self` in
  # any file. You can also access them as class methods on the module for use
  # inside of other classes, or include the module.
  #
  module DSL
    include Actions
    include Rules::Terse
    include ScriptHandling
    include Core::EntityLookup

    module_function

    #
    # Execute the supplied block after the specified duration
    #
    # @param [java.time.Duration] duration after which to execute the block
    # @param [Object] id to associate with timer
    # @param [Block] block to execute, block is passed a Timer object
    #
    # @return [Timer] Timer object
    #
    def after(duration, id: nil, &block)
      # Carry rule name to timer thread
      thread_locals = { OPENHAB_RULE_UID: Thread.current[:OPENHAB_RULE_UID] } if Thread.current[:OPENHAB_RULE_UID]
      thread_locals ||= {}
      return Timer::Manager.reentrant_timer(duration: duration, thread_locals: thread_locals, id: id, &block) if id

      OpenHAB::DSL::Timer.new(duration: duration, thread_locals: thread_locals, &block)
    end

    #
    # Creates a range that can be compared against time of day/month days or strings
    # to see if they are within the range
    #
    # @return [Range] object representing a TimeOfDay Range
    #
    def between(range)
      raise ArgumentError, "Supplied object must be a range" unless range.is_a?(Range)

      return :MonthDayRange.range(range) if MonthDayRange.range?(range)

      TimeOfDay.between(range)
    end

    #
    # Global method that takes a block and for the duration of the block
    # all commands sent will check if the item is in the command's state
    # before sending the command.
    #
    # @note Wrapping an entire rule or file in an ensure_states block will not
    #   ensure the states during execution of the rules. See examples.
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
    # @example This will not work
    #   ensure_states do
    #     rule 'Items in an execution block will not have ensure_states applied to them' do
    #       changed VirtualSwitch
    #       run do
    #         VirtualSwitch.on
    #         VirtualSwitch2.on
    #       end
    #     end
    #   end
    #
    # @example This will work
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
      old = Thread.current[:ensure_states]
      Thread.current[:ensure_states] = true
      yield
    ensure
      Thread.current[:ensure_states] = old
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
    # Sets a thread local variable to set the default persistence service
    # for method calls inside the block
    #
    # @param [Object] service service either as a String or a Symbol
    # @yield [] Block executed in context of the supplied persistence service
    # @return [Object] The return value from the block.
    #
    def persistence(service)
      Thread.current.thread_variable_set(:persistence_service, service)
      yield
    ensure
      Thread.current.thread_variable_set(:persistence_service, nil)
    end

    #
    # Create a new rule
    #
    # @see Terse
    #
    # @param [String] name The rule name
    # @yield Block executed in context of a {Rules::Builder}
    # @yieldparam [Rules::Builder] rule
    #   Optional parameter to access the rule configuration from within execution blocks and guards.
    # @return [void]
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
    def rule(name = nil, id: nil, script: nil, &block)
      id ||= Rules::NameInference.infer_rule_id_from_block(block)
      script ||= block.source rescue nil # rubocop:disable Style/RescueModifier

      builder = nil
      ThreadLocal.thread_local(OPENHAB_RULE_UID: id) do
        builder = Rules::Builder.new(block.binding)
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
      id ||= NameInference.infer_rule_id_from_block(block)
      name ||= id
      script ||= block.source rescue nil # rubocop:disable Style/RescueModifier

      builder = nil
      ThreadLocal.thread_local(RULE_NAME: name) do
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
    # @yieldparam [Core::Types::Command, nil] command
    #   The command being sent for `:command_from_item` and `:command_from_handler` events.
    # @yieldparam [Core::Types::State, nil] state
    #   The state being sent for `:state_from_item` and `:state_from_handler` events.
    # @yieldparam [Core::Things::ItemChannelLink] link
    #   The link between the item and the channel, including its configuration.
    # @yieldparam [Core::Items::GenericItem] item The linked item.
    # @yieldparam [org.openhab.core.thing.ChannelUID] channel_uid The linked channel.
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
      uid = org.openhab.core.thing.profiles.ProfileTypeUID.new("ruby", id)

      Core::ProfileFactory.instance.register(uid, block)
    end

    #
    # Remove a rule
    #
    # @return [void]
    #
    def remove_rule(uid)
      uid = uid.uid if uid.respond_to?(:uid)
      automation_rule = Rules.script_rules.delete(uid)
      raise "Rule #{rule_uid} doesn't exist to remove" unless automation_rule

      automation_rule.cleanup
      # automation_manager doesn't have a remove method, so just have to
      # remove it directly from the provider
      Rules.scripted_rule_provider.remove_rule(uid)
    end

    #
    # Store states of supplied items
    #
    # @param [Array] items to store states of
    #
    # @return [StateStorage] item states
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
    # Get all things known to OpenHAB
    #
    # @return [Things] all Thing objects known to OpenHAB
    #
    def things
      Core::Things::Registry.instance
    end

    #
    # Provides access to the hash for mapping timer ids to the set of active timers associated with that id
    # @return [Hash] hash of user specified ids to sets of times
    def timers
      Timer::Manager.instance.timer_ids
    end

    # @overload unit
    #  @return [javax.measure.unit] The current thread unit
    #
    # @overload unit(unit)
    #   Sets a thread local variable to the supplied unit such that classes
    #   operating inside the block can perform automatic conversions to the
    #   supplied unit for NumberItems.
    #
    #   To facilitate conversion of multiple dimensioned and dimensionless
    #   numbers the unit block may be used. The unit block attempts to do the
    #   _right thing_ based on the mix of dimensioned and dimensionless items
    #   within the block. Specifically all dimensionless items are converted to
    #   the supplied unit, except when they are used for multiplication or
    #   division.
    #
    #   @param [String, javax.measure.Unit] unit Unit or String representing unit
    #   @yield The block will be executed in the context of the specify unit.
    #
    #   @example
    #     # Number:Temperature NumberC = 23 °C
    #     # Number:Temperature NumberF = 70 °F
    #     # Number Dimensionless = 2
    #     unit('°F') { NumberC.state - NumberF.state < 4 }                                      # => true
    #     unit('°F') { NumberC.state - '24 °C' < 4 }                                            # => true
    #     unit('°F') { (24 | '°C') - NumberC.state < 4 }                                        # => true
    #     unit('°C') { NumberF.state - '20 °C' < 2 }                                            # => true
    #     unit('°C') { NumberF.state - Dimensionless.state }                                    # => 19.11 °C
    #     unit('°C') { NumberF.state - Dimensionless.state < 20 }                               # => true
    #     unit('°C') { Dimensionless.state + NumberC.state == 25 }                              # => true
    #     unit('°C') { 2 + NumberC.state == 25 }                                                # => true
    #     unit('°C') { Dimensionless.state * NumberC.state == 46 }                              # => true
    #     unit('°C') { 2 * NumberC.state == 46 }                                                # => true
    #     unit('°C') { ( (2 * (NumberF.state + NumberC.state) ) / Dimensionless.state ) < 45 }  # => true
    #     unit('°C') { [NumberC.state, NumberF.state, Dimensionless.state].min }                # => 2
    #
    def unit(unit = nil)
      return Thread.current[:unit] if unit.nil? && !block_given?
      raise "You must specify an argument for the block", ArgumentError if unit.nil? && block_given?
      raise "You must give a block to set the unit for the duration of", ArgumentError if !unit.nil? && !block_given?

      begin
        unit = org.openhab.core.types.util.UnitUtils.parse_unit(unit) if unit.is_a?(String)
        old_unit = Thread.current[:unit]
        Thread.current[:unit] = unit
        yield
      ensure
        Thread.current[:unit] = old_unit
      end
    end
  end
end

OpenHAB::Core::Things::Thing.include(OpenHAB::DSL::Actions)

OpenHAB::Core.wait_till_openhab_ready
OpenHAB::Core.add_rubylib_to_load_path

# import Items classes into global namespace
OpenHAB::Core::Items.import_into_global_namespace

# Extend `main` with DSL methods
singleton_class.include(OpenHAB::DSL)

OpenHAB::DSL.send(:logger).debug "OpenHAB JRuby Scripting Library Version #{OpenHAB::DSL::VERSION} Loaded"
