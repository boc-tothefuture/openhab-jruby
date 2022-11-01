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
    include Units
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
    # @yield
    # @return [Object] The result of the block.
    #
    # @example Turn on several switches only if they're not already on
    #   ensure_states do
    #     Switch1.on
    #     Switch2.on
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
