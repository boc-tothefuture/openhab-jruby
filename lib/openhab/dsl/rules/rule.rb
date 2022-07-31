# frozen_string_literal: true

require 'method_source'

require 'openhab/core/thread_local'
require 'openhab/core/services'
require 'openhab/log/logger'
require_relative 'rule_config'
require_relative 'automation_rule'
require_relative 'guard'
require_relative 'name_inference'

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
      # The main rule DSL method
      #
      module Rule
        include OpenHAB::Log

        @script_rules = []

        @automation_manager = OpenHAB::Core.automation_manager
        @registry = OpenHAB::Core.rule_registry
        class << self
          attr_reader :script_rules, :automation_manager, :registry
        end

        module_function

        #
        # Create a new rule
        #
        # @param [String] rule_name The rule name
        # @yield [] Block executed in context of a RuleConfig
        #
        #
        def rule(rule_name = nil, id: nil, script: nil, &block) # rubocop:disable Metrics
          id ||= NameInference.infer_rule_id_from_block(block)
          script ||= block.source rescue nil # rubocop:disable Style/RescueModifier

          OpenHAB::Core::ThreadLocal.thread_local(RULE_NAME: rule_name) do
            @rule_name = rule_name

            config = RuleConfig.new(block.binding)
            config.uid(id)
            config.instance_exec(config, &block)
            config.guard = Guard::Guard.new(run_context: config.caller, only_if: config.only_if,
                                            not_if: config.not_if)

            rule_name ||= NameInference.infer_rule_name(config)
            rule_name ||= id

            config.name(rule_name)
            logger.trace { config.inspect }
            process_rule_config(config, script)
          end
        rescue StandardError => e
          logger.log_exception(e, @rule_name)
        end

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
        def process_rule_config(config, script) # rubocop:disable Metrics
          return unless create_rule?(config)

          rule = AutomationRule.new(config: config)
          Rule.script_rules << rule
          added_rule = add_rule(rule)
          # add config so that MainUI can show the script
          added_rule.actions.first.configuration.put('type', 'application/x-ruby')
          added_rule.actions.first.configuration.put('script', script)

          rule.execute(nil, { 'event' => Struct.new(:attachment).new(config.start_attachment) }) if config.on_start?
          added_rule
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
        # @param [org.openhab.core.automation.module.script.rulesupport.shared.simple.SimpleRule] rule to add
        #
        #
        def add_rule(rule)
          base_uid = rule.uid
          duplicate_index = 1
          while $rules.get(rule.uid)
            duplicate_index += 1
            rule.uid = "#{base_uid} (#{duplicate_index})"
          end
          logger.trace("Adding rule: #{rule.inspect}")
          Rule.automation_manager.addRule(rule)
        end
      end
    end
  end
end
