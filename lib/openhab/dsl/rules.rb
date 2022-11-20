# frozen_string_literal: true

require_relative "script_handling"

module OpenHAB
  module DSL
    module Rules
      @script_rules = {}

      @scripted_rule_provider = OSGi.service(
        "org.openhab.core.automation.module.script.rulesupport.shared.ScriptedRuleProvider"
      )
      class << self
        # @!visibility private
        attr_reader :script_rules, :scripted_rule_provider

        #
        # Cleanup rules in this script file
        #
        # @return [void]
        #
        def cleanup_rules
          script_rules.each_value(&:cleanup)
        end
      end
      Core::ScriptHandling.script_unloaded { cleanup_rules }
    end
  end
end
