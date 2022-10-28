# frozen_string_literal: true

require "forwardable"
require_relative "property"
require_relative "triggers/triggers"
require_relative "guard"
require_relative "rule_triggers"
require "openhab/core/entity_lookup"
require "openhab/dsl/between"
require "openhab/dsl/timers"

module OpenHAB
  module DSL
    #
    # Creates and manages OpenHAB Rules
    #
    module Rules
      #
      # Rule configuration for OpenHAB Rules engine
      #
      class RuleConfig
        include OpenHAB::Core::EntityLookup
        prepend OpenHAB::DSL::Rules::Triggers
        include OpenHAB::DSL::Rules::Guard
        include OpenHAB::DSL::Rules::Property
        extend Forwardable

        # Provide backwards compatibility for these fields
        delegate %i[triggers trigger_conditions attachments] => :@rule_triggers

        # @!visibility private
        # @return [Array] Of trigger guards
        attr_accessor :guard

        # @!visibility private
        # @return [Object] object that invoked rule method
        attr_accessor :caller

        # @!visibility private
        # @return [Array] Of trigger definitions as passed in Ruby
        attr_reader :ruby_triggers

        # @!visibility private
        Run = Struct.new(:block)

        # @!visibility private
        Trigger = Struct.new(:block)

        # @!visibility private
        Otherwise = Struct.new(:block)

        # @!visibility private
        Delay = Struct.new(:duration)

        # @!group Execution Blocks

        #
        # @!method run
        #
        # Add a block that will be passed event data.
        #
        # @yieldparam [Event] event
        # @return [void]
        #
        prop_array :run, array_name: :run_queue, wrapper: Run

        #
        # @!method triggered
        #
        # Add a block that will be passed the triggering item.
        #
        # @yieldparam [Item] item
        # @return [void]
        #
        # @example
        #   rule "motion sensor triggered" do
        #     changed MotionSensor.members, to: :OPEN
        #     triggered do |item|
        #       logger.info("#{item.name} detected motion")
        #     end
        #   end
        #
        prop_array :triggered, array_name: :run_queue, wrapper: Trigger

        #
        # @!method delay(duration)
        #
        # Add a wait between or after run blocks.
        #
        # @param [Duration] duration How long to delay for.
        # @return [void]
        #
        # @example
        #   rule "delay execution" do
        #     changed MotionSensor, to: CLOSED
        #     delay 5.seconds
        #     run { Light.off }
        #   end
        #
        prop_array :delay, array_name: :run_queue, wrapper: Delay

        #
        # @!method otherwise
        #
        # Add a block that will be passed event data, to be run if guards are not satisfied.
        #
        # @yieldparam [Event] event
        #
        prop_array :otherwise, array_name: :run_queue, wrapper: Otherwise

        # @!group Configuration

        #
        # @!method uid(id)
        #
        # Set the rule's UID.
        #
        # @param [String] id
        # @return [void]
        #
        prop :uid

        #
        # @!method name(value)
        #
        # Set the fule's name.
        #
        # @param [String] value
        # @return [void]
        #
        prop :name

        #
        # @!method description(value)
        #
        # Set the rule's description.
        #
        # @param [String] value
        # @return [void]
        #
        prop :description

        #
        # @!method tags(tags)
        #
        # Set the rule's tags.
        #
        # @param [String, Class, Array<String, Class>] tags
        # @return [void]
        #
        # @example
        #   rule "tagged rule" do
        #     tags "lighting", "security"
        #   end
        #
        prop :tags

        #
        # @!method enabled(value)
        #
        # Enable or disable the rule from executing
        # @return [void]
        #
        # @example
        #   rule "disabled rule" do
        #     enabled(false)
        #   end
        #
        prop :enabled

        # @!group Guards

        #
        # @!method between(range)
        #
        # Only execute rule if current time is between supplied time ranges.
        #
        # @param [Range<TimeOfDay, String>] range
        # @return [void]
        #
        # @example
        #   rule "Between guard" do
        #     changed MotionSensor, to: OPEN
        #     between "6:05".."14:05:05" # Include end
        #     run { Light.on }
        #   end
        #
        # @example
        #   rule "Between guard" do
        #     changed MotionSensor, to: OPEN
        #     between "6:05".."14:05:05" # Excludes end second
        #     run { Light.on }
        #   end
        #
        # @example
        #   rule "Between guard" do
        #     changed MotionSensor, to: OPEN
        #     between TimeOfDay.new(h:6,m:5)..TimeOfDay.new(h:14,m:15,s:5)
        #     run { Light.on }
        #   end
        #
        prop :between

        # @!endgroup

        # @!visibility private
        #
        # Create a new RuleConfig
        #
        # @param [Object] caller_binding The object initializing this configuration.
        #   Used to execute within the object's context
        #
        def initialize(caller_binding)
          @rule_triggers = RuleTriggers.new
          @caller = caller_binding.eval "self"
          @ruby_triggers = []
          enabled(true)
          on_start(false)
          tags([])
        end

        # @!group Triggers
        #
        # Run this rule when the script is loaded.
        #
        # @param [true, false] run_on_start Run this rule on start, defaults to True
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #   rule "startup rule" do
        #     on_start
        #     run do
        #       <calculate some item state>
        #     end
        #   end
        #
        # rubocop:disable Style/OptionalBooleanParameter
        def on_start(run_on_start = true, attach: nil)
          @on_start = Struct.new(:enabled, :attach).new(run_on_start, attach)
        end
        # rubocop:enable Style/OptionalBooleanParameter

        # @!endgroup

        #
        # Checks if this rule should run on start
        #
        # @return [true, false] True if rule should run on start, false otherwise.
        #
        def on_start?
          @on_start.enabled
        end

        #
        # Get the optional start attachment
        #
        # @return [Object] optional user provided attachment to the on_start method
        #
        def start_attachment
          @on_start.attach
        end

        # @!visibility private
        #
        # Run the supplied block inside the object instance of the object that created the rule config
        #
        # @yield [] Block executed in context of the object creating the rule config
        #
        #
        def my(&block)
          @caller.instance_eval(&block)
        end

        #
        # Inspect the config object
        #
        # @return [String] details of the config object
        #
        def inspect
          "Name: (#{name}) " \
            "Triggers: (#{triggers}) " \
            "Run blocks: (#{run}) " \
            "on_start: (#{on_start?}) " \
            "Trigger Conditions: #{trigger_conditions} " \
            "Trigger UIDs: #{triggers.map(&:id).join(", ")} " \
            "Attachments: #{attachments}"
        end

        private

        # delegate to the caller's logger
        def logger
          @caller.logger
        end
      end
    end
  end
end
