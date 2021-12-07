# frozen_string_literal: true

module OpenHAB
  #
  # Core support for OpenHAB JRuby Library
  #
  module Core
    #
    # Access OpenHAB services
    #

    # Get the OpenHAB automation manager
    # @return [AutomationManager] OpenHAB Automation manager
    # rubocop:disable Style/GlobalVars
    def self.automation_manager
      $scriptExtension.get('automationManager')
    end

    # Get the OpenHAB rule registry
    # @return [Registory] OpenHAB rule registry
    def self.rule_registry
      $scriptExtension.get('ruleRegistry')
    end
    # rubocop:enable Style/GlobalVars
  end
end
