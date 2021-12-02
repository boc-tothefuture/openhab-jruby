# frozen_string_literal: true

require 'openhab/core/thread_local'
require 'openhab/log/logger'
require_relative 'rule_config'
require_relative 'automation_rule'
require_relative 'cron_trigger_rule'
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

      # rubocop: disable Style/GlobalVars
      @automation_manager = $scriptExtension.get('automationManager')
      @registry = $scriptExtension.get('ruleRegistry')
      # rubocop: enable Style/GlobalVars

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
          config.guard = Guard::Guard.new(only_if: config.only_if, not_if: config.not_if)
          logger.trace { config.inspect }
          process_rule_config(config)
          nil # Must return something other than the rule object. See https://github.com/boc-tothefuture/openhab-jruby/issues/438
        end
      rescue StandardError => e
        puts "#{e.class}: #{e.message}"
        re_raise_with_backtrace(e)
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
      # Re-raises a rescued error to OpenHAB with added rule name and stack trace
      #
      # @param [Exception] error A rescued error
      #
      def re_raise_with_backtrace(error)
        error = logger.clean_backtrace(error)
        raise error, "#{error.message}\nIn rule: #{@rule_name}\n#{error.backtrace.join("\n")}"
      end

      #
      # Process a rule based on the supplied configuration
      #
      # @param [RuleConfig] config for rule
      #
      #
      def process_rule_config(config)
        return unless create_rule?(config)

        cron_attach_triggers, other_triggers = partition_triggers(config)
        logger.trace("Cron triggers: #{cron_attach_triggers} -  Other triggers: #{other_triggers}")
        config.triggers = other_triggers

        rule = AutomationRule.new(config: config)
        Rules.script_rules << rule
        add_rule(rule)

        process_cron_attach(cron_attach_triggers, config, rule)

        rule.execute(nil, { 'event' => Struct.new(:attachment).new(config.start_attachment) }) if config.on_start?
        rule
      end

      #
      # Add cron triggers with attachments to rules
      # @param [Array] cron_attach_triggers cron type triggers with attachments
      #
      def process_cron_attach(cron_attach_triggers, config, rule)
        cron_attach_triggers&.map { |trigger| CronTriggerRule.new(rule_config: config, rule: rule, trigger: trigger) }
                            &.each { |trigger| add_rule(trigger) }
      end

      #
      # Partitions triggers in a config, removing cron triggers with a corresponding attachment
      # so they can be used with CronTriggerRules to support attachments
      # @return [Array] Two element array the first element is cron triggers with attachments,
      #   second element is other triggers
      #
      def partition_triggers(config)
        config
          .triggers
          .partition do |trigger|
          trigger.typeUID == OpenHAB::DSL::Rules::Triggers::Trigger::CRON &&
            config.attachments.key?(trigger.id)
        end
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
