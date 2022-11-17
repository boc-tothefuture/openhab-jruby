# frozen_string_literal: true

Dir[File.expand_path("core/**/*.rb", __dir__)].sort.each do |f|
  require f
end

module OpenHAB
  # Contains classes and modules that wrap actual OpenHAB objects
  module Core
    # The OpenHAB Version. >= 3.3.0 is required.
    # @return [String]
    VERSION = org.openhab.core.OpenHAB.version.freeze

    unless Gem::Version.new(VERSION) >= Gem::Version.new("3.3.0")
      raise "`openhab-jrubyscripting` requires OpenHAB >= 3.3.0"
    end

    # @return [Integer] Number of seconds to wait between checks for automation manager
    CHECK_DELAY = 10
    private_constant :CHECK_DELAY
    class << self
      #
      # Wait until OpenHAB engine ready to process
      #
      # @return [void]
      #
      # @!visibility private
      def wait_till_openhab_ready
        logger.trace("Checking readiness of OpenHAB")
        until automation_manager
          logger.trace("Automation manager not loaded, checking again in #{CHECK_DELAY} seconds.")
          sleep CHECK_DELAY
        end
        logger.trace "Automation manager instantiated, OpenHAB ready for rule processing."
      end

      #
      # @!attribute [r] config_folder
      # @return [Pathname] The configuration folder path.
      #
      def config_folder
        Pathname.new(org.openhab.core.OpenHAB.config_folder)
      end

      #
      # @!attribute [r] automation_manager
      # @return [org.openhab.core.automation.module.script.rulesupport.shared.ScriptedAutomationManager]
      #   The OpenHAB Automation manager.
      #
      def automation_manager
        $scriptExtension.get("automationManager")
      end

      #
      # @!attribute [r] rule_registry
      # @return [org.openhab.core.automation.RuleRegistry] The OpenHAB rule registry
      #
      def rule_registry
        $scriptExtension.get("ruleRegistry")
      end

      #
      # @!attribute [r] rule_manager
      # @return [org.openhab.core.automation.RuleManager] The OpenHAB rule manager/engine
      #
      def rule_manager
        @rule_manager ||= OSGi.service("org.openhab.core.automation.RuleManager")
      end
    end
  end
end
