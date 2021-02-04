# frozen_string_literal: true

require 'java'
require 'pp'
require 'core/dsl/property'
require 'core/dsl/rule/cron'
require 'core/dsl/rule/triggers'
require 'core/dsl/rule/item'
require 'core/dsl/rule/channel'
require 'core/dsl/rule/guard'
require 'core/dsl/entities'
require 'core/dsl/time_of_day'
require 'core/dsl'
require 'core/dsl/timers'

module OpenHAB
  module Core
    #
    # Contains code to create an OpenHAB DSL
    #
    module DSL
      #
      # Creates and manages OpenHAB Rules
      #
      module Rule
        #
        # Create a new rule
        #
        # @param [String] name <description>
        # @yield [] Block executed in context of a RuleConfig
        #
        #
        def rule(name, &block)
          config = RuleConfig.new(name, block.binding)
          config.instance_eval(&block)
          config.guard = Guard::Guard.new(only_if: config.only_if, not_if: config.not_if)
          logger.trace { config.inspect }
          process_rule_config(config)
        end

        #
        # Create a logger where name includes rule name if name is set
        #
        # @return [Logging::Logger] Logger with name that appended with rule name if rule name is set
        #
        def logger
          if name
            Logging.logger(name.chomp.gsub(/\s+/, '_'))
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
          if !config.on_start? && config.triggers.empty?
            logger.warn "#{config.name} has no triggers, not creating rule"
          elsif config.enabled
            rule = Rule.new(config: config)
            add_rule(rule)
            rule.execute if config.on_start?
          else
            logger.debug "#{config.name} marked as disabled, not creating rule."
          end
        end
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
