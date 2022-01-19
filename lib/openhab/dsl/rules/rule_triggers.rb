# frozen_string_literal: true

require 'forwardable'
require 'java'
require 'securerandom'
require 'openhab/log/logger'
require_relative 'triggers/conditions/proc'

module OpenHAB
  module DSL
    #
    # Creates and manages OpenHAB Rules
    #
    module Rules
      #
      # Rule configuration for OpenHAB Rules engine
      #
      class RuleTriggers
        include OpenHAB::Log

        java_import org.openhab.core.automation.util.TriggerBuilder
        java_import org.openhab.core.config.core.Configuration

        # @return [Array] Of triggers
        attr_accessor :triggers

        # @return [Hash] Of trigger conditions
        attr_reader :trigger_conditions

        # @return [Hash] Hash of trigger UIDs to attachments
        attr_reader :attachments

        #
        # Create a new RuleTrigger
        #
        # @param [Object] caller_binding The object initializing this configuration.
        #   Used to execute within the object's context
        #
        def initialize
          @triggers = []
          @trigger_conditions = Hash.new(OpenHAB::DSL::Rules::Triggers::Conditions::Proc::ANY)
          @attachments = {}
        end

        #
        # Append a trigger to the list of triggers
        #
        # @param [String] type of trigger to create
        # @param [Map] config map describing trigger configuration
        #
        # @return [Trigger] OpenHAB trigger
        #
        def append_trigger(type:, config:, attach: nil, conditions: nil)
          config.transform_keys!(&:to_s)
          RuleTriggers.trigger(type: type, config: config).tap do |trigger|
            logger.trace("Appending trigger (#{trigger}) attach (#{attach}) conditions(#{conditions})")
            @triggers << trigger
            @attachments[trigger.id] = attach if attach
            @trigger_conditions[trigger.id] = conditions if conditions
          end
        end

        #
        # Create a trigger
        #
        # @param [String] type of trigger
        # @param [Map] config map
        #
        # @return [OpenHAB Trigger] configured by type and supplied config
        #
        def self.trigger(type:, config:)
          logger.trace("Creating trigger of type '#{type}' config: #{config}")
          TriggerBuilder.create
                        .with_id(uuid)
                        .with_type_uid(type)
                        .with_configuration(Configuration.new(config))
                        .build
        end

        #
        # Generate a UUID for triggers
        #
        # @return [String] UUID
        #
        def self.uuid
          SecureRandom.uuid
        end

        #
        # Inspect the config object
        #
        # @return [String] details of the config object
        #
        def inspect
          "Triggers: (#{triggers}) " \
            "Trigger Conditions: #{trigger_conditions} " \
            "Trigger UIDs: #{triggers.map(&:id).join(', ')}" \
            "Attachments: #{attachments} "
        end
      end
    end
  end
end
