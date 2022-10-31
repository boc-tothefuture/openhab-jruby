# frozen_string_literal: true

require "forwardable"

require_relative "property"
require_relative "guard"
require_relative "rule_triggers"

Dir[File.expand_path("triggers/*.rb", __dir__)].sort.each do |f|
  require f
end

module OpenHAB
  module DSL
    #
    # Creates and manages OpenHAB Rules
    #
    module Rules
      #
      # Rule configuration for OpenHAB Rules engine
      #
      class Builder
        include DSL
        prepend Triggers
        include Property
        extend Forwardable

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

        #
        # @!method only_if
        #
        # {only_if} allows rule execution when the block's is true and prevents it when it's false.
        #
        # @yieldparam [Core::Events::AbstractEvent] event The event data that is about to trigger the rule.
        # @yieldreturn [Boolean] A value indicating if the rule should run.
        # @return [void]
        #
        # @example
        #   rule "Set OutsideDimmer to 50% if LightSwitch turned on and OtherSwitch is also ON" do
        #     changed LightSwitch, to: ON
        #     run { OutsideDimmer << 50 }
        #     only_if { OtherSwitch.on? }
        #   end
        #
        # @example Multiple {only_if} statements can be used and *all* must be true for the rule to run.
        #   rule "Set OutsideDimmer to 50% if LightSwitch turned on and OtherSwitch is also ON and Door is closed" do
        #     changed LightSwitch, to: ON
        #     run { OutsideDimmer << 50 }
        #     only_if { OtherSwitch.on? }
        #     only_if { Door.closed? }
        #   end
        #
        prop_array(:only_if) do |item|
          unless item.is_a?(Proc) || [item].flatten.all? { |it| it.respond_to?(:truthy?) }
            raise ArgumentError, "Object passed to only_if must be a proc"
          end
        end

        #
        # @!method not_if
        #
        # {not_if} prevents execution of rules when the block's result is true and allows it when it's true.
        #
        # @yieldparam [Core::Events::AbstractEvent] event The event data that is about to trigger the rule.
        # @yieldreturn [Boolean] A value indicating if the rule should _not_ run.
        # @return [void]
        #
        # @example
        #   rule "Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF" do
        #     changed LightSwitch, to: ON
        #     run { OutsideDimmer << 50 }
        #     not_if { OtherSwitch.on? }
        #   end
        #
        # @example Multiple {not_if} statements can be used and if **any** of them are not satisfied the rule will not run. # rubocop:disable Style/LineLength
        #   rule "Set OutsideDimmer to 50% if LightSwitch turned on and OtherSwitch is OFF and Door is not CLOSED" do
        #     changed LightSwitch, to: ON
        #     run { OutsideDimmer << 50 }
        #     not_if { OtherSwitch.on? }
        #     not_if { Door.closed? }
        #   end
        #
        prop_array(:not_if) do |item|
          unless item.is_a?(Proc) || [item].flatten.all? { |it| it.respond_to?(:truthy?) }
            raise ArgumentError, "Object passed to not_if must be a proc"
          end
        end

        # @!endgroup

        # @!visibility private
        #
        # Create a new DSL
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
        # Run the supplied block inside the object instance of the object that created the rule
        #
        # @yield [] Block executed in context of the object creating the rule
        #
        #
        def my(&block)
          @caller.instance_eval(&block)
        end

        #
        # @return [String]
        #
        def inspect
          <<~TEXT.tr("\n", " ")
            #<OpenHAB::DSL::Rules::Builder: #{uid}
            triggers=#{triggers.inspect},
            run blocks=#{run.inspect},
            on_start=#{on_start?},
            Trigger Conditions=#{trigger_conditions.inspect},
            Trigger UIDs=#{triggers.map(&:id).inspect},
            Attachments=#{attachments.inspect}
            >
          TEXT
        end

        #
        # Process a rule based on the supplied configuration
        #
        # @param [String] script The source code of the rule
        #
        # @!visibility private
        def build(script)
          return unless create_rule?

          rule = AutomationRule.new(config: self)
          added_rule = add_rule(rule)
          Rules.script_rules[rule.uid] = rule
          # add config so that MainUI can show the script
          added_rule.actions.first.configuration.put("type", "application/x-ruby")
          added_rule.actions.first.configuration.put("script", script)

          rule.execute(nil, { "event" => Struct.new(:attachment).new(start_attachment) }) if on_start?
          added_rule
        end

        private

        # delegate to the caller's logger
        def logger
          @caller.logger
        end

        #
        # Should a rule be created based on rule configuration
        #
        # @return [true,false] true if it should be created, false otherwise
        #
        def create_rule?
          if !triggers?
            logger.warn "Rule '#{uid}' has no triggers, not creating rule"
          elsif !execution_blocks?
            logger.warn "Rule '#{uid}' has no execution blocks, not creating rule"
          elsif !enabled
            logger.trace "Rule '#{uid}' marked as disabled, not creating rule."
          else
            return true
          end
          false
        end

        #
        # Check if the rule has any triggers
        #
        # @return [true,false] True if rule has triggers, false otherwise
        #
        def triggers?
          on_start? || !triggers.empty?
        end

        #
        # Check if the rule has any execution blocks
        #
        # @return [true,false] True if rule has execution blocks, false otherwise
        #
        def execution_blocks?
          !(run || []).empty?
        end

        #
        # Add a rule to the automation manager
        #
        # @param [org.openhab.core.automation.module.script.rulesupport.shared.simple.SimpleRule] rule to add
        #
        #
        def add_rule(rule)
          base_uid = rule.uid
          duplicate_index = 1
          while $rules.get(rule.uid)
            duplicate_index += 1
            rule.uid = "#{base_uid} (#{duplicate_index})"
          end
          logger.trace("Adding rule: #{rule}")
          Core.automation_manager.add_rule(rule)
        end
      end
    end
  end
end
