# frozen_string_literal: true

require 'java'
require 'openhab/log/logger'

module OpenHAB
  module DSL
    #
    # Creates and manages OpenHAB Rules
    #
    module Rules
      #
      # Specialized rule for cron triggers with attachments because OpenHAB does not provide trigger UID for cron rules
      #
      class CronTriggerRule < Java::OrgOpenhabCoreAutomationModuleScriptRulesupportSharedSimple::SimpleRule
        include OpenHAB::Log

        def initialize(rule_config:, rule:, trigger:)
          super()
          set_name("#{rule_config.name}-cron-#{trigger.id}")
          set_triggers([trigger])
          @rule = rule
          @trigger = trigger
          logger.trace("Created Cron Trigger Rule for #{@trigger}")
        end

        #
        # Execute the rule
        #
        # @param [Map] mod map provided by OpenHAB rules engine
        # @param [Map] inputs map provided by OpenHAB rules engine containing event and other information
        #
        #
        def execute(mod = nil, _inputs = nil)
          logger.trace "Trigger #{@trigger} fired for base rule #{@rule.inspect}"
          inputs = { 'module' => @trigger.id }
          @rule.execute(mod, inputs)
        end
      end
    end
  end
end
