# frozen_string_literal: true

require 'java'
require 'pp'
require 'openhab/dsl/rules/property'
require 'openhab/dsl/rules/triggers/cron'
require 'openhab/dsl/rules/triggers/changed'
require 'openhab/dsl/rules/triggers/channel'
require 'openhab/dsl/rules/triggers/command'
require 'openhab/dsl/rules/triggers/updated'
require 'openhab/dsl/rules/triggers/generic'
require 'openhab/dsl/rules/guard'
require 'openhab/core/entity_lookup'
require 'openhab/dsl/between'
require 'openhab/dsl/dsl'
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
        extend OpenHAB::DSL

        # @return [Array] Of triggers
        attr_reader :triggers

        # @return [Array] Of trigger delays
        attr_reader :trigger_delays

        # @return [Hash] Hash of trigger UIDs to attachments
        attr_reader :attachments

        # @return [Array] Of trigger guards
        attr_accessor :guard

        # @return [Object] object that invoked rule method
        attr_accessor :caller

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
        def initialize(rule_name, caller_binding)
          @triggers = []
          @trigger_delays = {}
          @attachments = {}
          @caller = caller_binding.eval 'self'
          enabled(true)
          on_start(false)
          name(rule_name)
        end

        #
        # Start this rule on system startup
        #
        # @param [Boolean] run_on_start Run this rule on start, defaults to True
        #
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
            "Trigger Waits: #{trigger_delays} " \
            "Trigger UIDs: #{triggers.map(&:id).join(', ')}" \
            "Attachments: #{attachments} "
        end
      end
    end
  end
end
