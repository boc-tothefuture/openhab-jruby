# frozen_string_literal: true

require 'openhab/dsl/rules/rule_config'
require 'openhab/dsl/rules/automation_rule'
require 'openhab/dsl/rules/guard'

module OpenHAB
  #
  # Contains code to create an OpenHAB DSL
  #
  module DSL
    #
    # Creates and manages OpenHAB Rules
    #
    module Rules
      #
      # Create a new rule
      #
      # @param [String] rule_name <description>
      # @yield [] Block executed in context of a RuleConfig
      #
      #
      def rule(rule_name, &block)
        @rule_name = rule_name
        config = RuleConfig.new(rule_name, block.binding)
        config.instance_eval(&block)
        config.guard = Guard::Guard.new(only_if: config.only_if, not_if: config.not_if)
        logger.trace { config.inspect }
        process_rule_config(config)
      end

      #
      # Create a logger where name includes rule name if name is set
      #
      # @return [Log::Logger] Logger with name that appended with rule name if rule name is set
      #
      def logger
        if @rule_name
          Log.logger(@rule_name.chomp.gsub(/\s+/, '_'))
        else
          super
        end
      end

      private

      #
      # Process a rule based on the supplied configuration
      #
      # @param [RuleConfig] config for rule
      #
      #
      def process_rule_config(config)
        return unless create_rule?(config)

        rule = AutomationRule.new(config: config)
        add_rule(rule)
        rule.execute if config.on_start?
      end

      #
      # Should a rule be created based on rule configuration
      #
      # @param [RuleConfig] config to check
      #
      # @return [Boolean] true if it should be created, false otherwise
      #
      def create_rule?(config)
        if !triggers?(config)
          logger.warn "Rule '#{config.name}' has no triggers, not creating rule"
        elsif !execution_blocks?(config)
          logger.warn "Rule '#{config.name}' has no execution blocks, not creating rule"
        elsif !config.enabled
          logger.debug "Rule '#{config.name}' marked as disabled, not creating rule."
        else
          return true
        end
        false
      end

      #
      # Check if the rule has any triggers
      #
      # @param [RuleConfig] config to check for triggers
      #
      # @return [Boolean] True if rule has triggers, false otherwise
      #
      def triggers?(config)
        config.on_start? || config.triggers.length.positive?
      end

      #
      # Check if the rule has any execution blocks
      #
      # @param [RuleConfig] config to check for triggers
      #
      # @return [Boolean] True if rule has execution blocks, false otherwise
      #
      def execution_blocks?(config)
        (config.run || []).length.positive?
      end

      #
      # Add a rule to the automation managed
      #
      # @param [Java::OrgOpenhabCoreAutomationModuleScriptRulesupportSharedSimple::SimpleRule] rule to add
      #
      #
      def add_rule(rule)
        # rubocop: disable Style/GlobalVars
        $scriptExtension.get('automationManager').addRule(rule)
        # rubocop: enable Style/GlobalVars
      end
    end
  end
end
