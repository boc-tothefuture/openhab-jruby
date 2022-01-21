# frozen_string_literal: true

require 'java'
require_relative 'cron'

module OpenHAB
  module DSL
    module Rules
      #
      # Cron type rules
      #
      module Triggers
        #
        # Cron trigger handler that provides trigger ID
        #
        module CronHandler
          include OpenHAB::Log

          #
          # Creates trigger types and trigger type factories for OpenHAB
          #
          def self.add_script_cron_handler
            java_import org.openhab.core.automation.type.TriggerType
            OpenHAB::Core.automation_manager.add_trigger_handler(
              OpenHAB::DSL::Rules::Triggers::Cron::CRON_TRIGGER_MODULE_ID,
              OpenHAB::DSL::Rules::Triggers::CronHandler::CronTriggerHandlerFactory.new
            )

            OpenHAB::Core.automation_manager.add_trigger_type(cron_trigger_type)
            OpenHAB::Log.logger(self).trace('Added script cron trigger handler')
          end

          #
          # Creates trigger types and trigger type factories for OpenHAB
          #
          private_class_method def self.cron_trigger_type
            TriggerType.new(
              OpenHAB::DSL::Rules::Triggers::Cron::CRON_TRIGGER_MODULE_ID,
              nil,
              'A specific instant occurs',
              'Triggers when the specified instant occurs',
              nil,
              org.openhab.core.automation.Visibility::VISIBLE,
              nil
            )
          end

          # Cron Trigger Handler that provides trigger IDs
          # Unfortunatly because the CronTriggerHandler in OpenHAB core is marked internal
          # the entire thing must be recreated here
          class CronTriggerHandler < org.openhab.core.automation.handler.BaseTriggerModuleHandler
            include OpenHAB::Log
            include org.openhab.core.scheduler.SchedulerRunnable
            include org.openhab.core.automation.handler.TimeBasedTriggerHandler

            # Provides access to protected fields
            field_accessor :callback

            # Creates a new CronTriggerHandler
            # @param [Trigger] OpenHAB trigger associated with handler
            #
            def initialize(trigger)
              @trigger = trigger
              @scheduler = OpenHAB::Core::OSGI.service('org.openhab.core.scheduler.CronScheduler')
              @expression = trigger.configuration.get('cronExpression')
              super(trigger)
            end

            #
            # Set the callback to execute when cron trigger fires
            # @param [Object] callback to run
            #
            def setCallback(callback) # rubocop:disable Naming/MethodName
              synchronized do
                super(callback)
                @scheduler.schedule(self, @expression)
                logger.trace("Scheduled cron job '#{@expression}' for trigger '#{@trigger.id}'.")
              end
            end

            #
            # Get the temporal adjuster
            # @return [CronAdjuster]
            #
            def getTemporalAdjuster # rubocop:disable Naming/MethodName
              org.openhab.core.scheduler.CronAdjuster.new(expression)
            end

            #
            # Execute the callback
            #
            def run
              callback&.triggered(@trigger, { 'module' => @trigger.id })
            end

            #
            # Displose of the handler
            # cancel the cron scheduled task
            #
            def dispose
              synchronized do
                super
                return unless @schedule

                @schedule&.cancel(true)
              end
              logger.trace("cancelled job for trigger '#{@trigger.id}'.")
            end
          end

          # Implements the ScriptedTriggerHandlerFactory interface to create a new Cron Trigger Handler
          class CronTriggerHandlerFactory
            include org.openhab.core.automation.module.script.rulesupport.shared.factories.ScriptedTriggerHandlerFactory

            # Invoked by the OpenHAB core to get a trigger handler for the supllied trigger
            # @param [Trigger] OpenHAB trigger
            #
            # @return [WatchTriggerHandler] trigger handler for supplied trigger
            def get(trigger)
              CronTriggerHandler.new(trigger)
            end
          end
        end
      end
    end
  end
end

# Add the cron handler to OpenHAB
OpenHAB::DSL::Rules::Triggers::CronHandler.add_script_cron_handler
