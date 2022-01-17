# frozen_string_literal: true

require 'openhab/core/thread_local'
require 'openhab/core/services'
require 'openhab/log/logger'
require_relative 'rule_config'
require_relative 'automation_rule'
require_relative 'guard'

module OpenHAB
  #
  # Contains code to create an OpenHAB DSL
  #
  module DSL
    #
    # Creates and manages OpenHAB Rules
    #
    module Rules
      include OpenHAB::Core::ThreadLocal
      include OpenHAB::Log

      @script_rules = []

      @automation_manager = OpenHAB::Core.automation_manager
      @registry = OpenHAB::Core.rule_registry
      class << self
        attr_reader :script_rules, :automation_manager, :registry
      end

      #
      # Create a new rule
      #
      # @param [String] rule_name <description>
      # @yield [] Block executed in context of a RuleConfig
      #
      #
      # rubocop: disable Metrics/MethodLength
      def rule(rule_name, &block)
        thread_local(RULE_NAME: rule_name) do
          @rule_name = rule_name
          config = RuleConfig.new(rule_name, block.binding)
          config.instance_exec(config, &block)
          config.guard = Guard::Guard.new(run_context: config.caller, only_if: config.only_if, not_if: config.not_if)
          logger.trace { config.inspect }
          process_rule_config(config)
          nil # Must return something other than the rule object. See https://github.com/boc-tothefuture/openhab-jruby/issues/438
        end
      rescue StandardError => e
        logger.log_exception(e, @rule_name)
      end
      # rubocop: enable Metrics/MethodLength

      #
      # Cleanup rules in this script file
      #
      def self.cleanup_rules
        @script_rules.each(&:cleanup)
      end
      Core::ScriptHandling.script_unloaded { cleanup_rules }

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
        Rules.script_rules << rule
        add_rule(rule)

        rule.execute(nil, { 'event' => Struct.new(:attachment).new(config.start_attachment) }) if config.on_start?
        rule
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
          logger.trace "Rule '#{config.name}' marked as disabled, not creating rule."
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
        logger.trace("Adding rule: #{rule.inspect}")
        Rules.automation_manager.addRule(rule)
      end
    end
  end
end
