# frozen_string_literal: true

require 'java'
require 'forwardable'
require_relative 'property'
require_relative 'triggers/triggers'
require_relative 'guard'
require_relative 'rule_triggers'
require 'openhab/core/entity_lookup'
require 'openhab/dsl/between'
require 'openhab/dsl/timers'

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
        include OpenHAB::Log
        include OpenHAB::Core::EntityLookup
        prepend OpenHAB::DSL::Rules::Triggers
        include OpenHAB::DSL::Rules::Guard
        include OpenHAB::DSL::Rules::Property
        extend Forwardable

        # Provide backwards compatibility for these fields
        delegate %i[triggers trigger_conditions attachments] => :@rule_triggers

        # @return [Array] Of trigger guards
        attr_accessor :guard

        # @return [Object] object that invoked rule method
        attr_accessor :caller

        # @return [Array] Of trigger definitions as passed in Ruby
        attr_reader :ruby_triggers

        #
        # Struct holding a run block
        #
        Run = Struct.new(:block)

        #
        # Struct holding a Triggered block
        #
        Trigger = Struct.new(:block)

        #
        # Struct holding an otherwise block
        #
        Otherwise = Struct.new(:block)

        #
        # Struct holding rule delays
        #
        Delay = Struct.new(:duration)

        prop_array :run, :array_name => :run_queue, :wrapper => Run
        prop_array :triggered, :array_name => :run_queue, :wrapper => Trigger
        prop_array :delay, :array_name => :run_queue, :wrapper => Delay
        prop_array :otherwise, :array_name => :run_queue, :wrapper => Otherwise

        prop :uid
        prop :name
        prop :description
        prop :enabled
        prop :between

        #
        # Create a new RuleConfig
        #
        # @param [Object] caller_binding The object initializing this configuration.
        #   Used to execute within the object's context
        #
        def initialize(caller_binding)
          @rule_triggers = RuleTriggers.new
          @caller = caller_binding.eval 'self'
          @ruby_triggers = []
          enabled(true)
          on_start(false)
        end

        #
        # Start this rule on system startup
        #
        # @param [Boolean] run_on_start Run this rule on start, defaults to True
        # @param [Object] attach object to be attached to the trigger
        #
        # rubocop: disable Style/OptionalBooleanParameter
        # Disabled cop due to use in a DSL
        def on_start(run_on_start = true, attach: nil)
          @on_start = Struct.new(:enabled, :attach).new(run_on_start, attach)
        end
        # rubocop: enable Style/OptionalBooleanParameter

        #
        # Checks if this rule should run on start
        #
        # @return [Boolean] True if rule should run on start, false otherwise.
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
            "Trigger UIDs: #{triggers.map(&:id).join(', ')} " \
            "Attachments: #{attachments}"
        end
      end
    end
  end
end
