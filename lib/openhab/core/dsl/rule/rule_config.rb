# frozen_string_literal: true

require 'java'
require 'pp'
require 'core/dsl/property'
require 'core/dsl/rule/triggers/cron'
require 'core/dsl/rule/triggers/changed'
require 'core/dsl/rule/triggers/channel'
require 'core/dsl/rule/triggers/command'
require 'core/dsl/rule/triggers/updated'
require 'core/dsl/rule/guard'
require 'core/dsl/entities'
require 'core/dsl/time_of_day'
require 'core/dsl'
require 'core/dsl/timers'

module OpenHAB
  module Core
    module DSL
      #
      # Creates and manages OpenHAB Rules
      #
      module Rule
        #
        # Rule configuration for OpenHAB Rules engine
        #
        class RuleConfig
          include EntityLookup
          include OpenHAB::Core::DSL::Rule::Triggers
          include Guard
          include DSLProperty
          include Logging
          extend OpenHAB::Core::DSL

          java_import org.openhab.core.library.items.SwitchItem

          # @return [Array] Of triggers
          attr_reader :triggers

          # @return [Array] Of trigger delays
          attr_reader :trigger_delays

          # @return [Array] Of trigger guards
          attr_accessor :guard

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

          prop_array :run, array_name: :run_queue, wrapper: Run
          prop_array :triggered, array_name: :run_queue, wrapper: Trigger
          prop_array :delay, array_name: :run_queue, wrapper: Delay
          prop_array :otherwise, array_name: :run_queue, wrapper: Otherwise

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
          def on_start(run_on_start = true)
            @on_start = run_on_start
          end
          # rubocop: enable Style/OptionalBooleanParameter

          #
          # Checks if this rule should run on start
          #
          # @return [Boolean] True if rule should run on start, false otherwise.
          #
          def on_start?
            @on_start
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
          # Create a logger where name includes rule name if name is set
          #
          # @return [Logging::Logger] Logger with name that appended with rule name if rule name is set
          #
          def logger
            if name
              Logging.logger(name.chomp.gsub(/\s+/, '_'))
            else
              super
            end
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
            "Trigger UIDs: #{triggers.map(&:id).join(', ')}"
          end
        end
      end
    end
  end
end
