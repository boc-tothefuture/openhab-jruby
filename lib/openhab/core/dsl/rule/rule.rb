# frozen_string_literal: true

require 'java'
require 'core/dsl/property'
require 'core/dsl/rule/cron'
require 'core/dsl/rule/triggers'
require 'core/dsl/rule/item'
require 'core/dsl/rule/guard'
require 'core/dsl/items'
require 'core/dsl/entities'
require 'core/dsl/actions'
require 'core/dsl/time_of_day'

module Rule
  class RuleConfig
    include EntityLookup
    include Cron
    include Triggers
    include Guard
    include Item
    include Items
    include DSLProperty
    include Actions
    include Logging

    java_import org.openhab.core.library.items.SwitchItem

    attr_reader :triggers

    Run = Struct.new(:block)
    Trigger = Struct.new(:block)
    Delay = Struct.new(:duration)

    prop_array :run, array_name: :run_queue, wrapper: Run
    prop_array :triggered, array_name: :run_queue, wrapper: Trigger
    prop_array :delay, array_name: :run_queue, wrapper: Delay
    prop :name
    prop :enabled
    prop :between

    def initialize(caller_binding)
      @triggers = []
      @enabled = true
      @on_start = false
      @caller = caller_binding.eval 'self'
    end

    def on_start(run_on_start = true)
      @on_start = run_on_start
    end

    def on_start?
      @on_start
    end

    def method_missing(name, *args, &block)
      lookup_item(name) || super
    end

    def my(&block)
      @caller.instance_eval(&block)
    end
  end

  def rule(name, &block)
    config = RuleConfig.new(block.binding)
    config.name(name)
    config.instance_eval(&block)
    unless config.on_start?
      return if config.triggers.empty?
    end

    guard = Guard::Guard.new(only_if: config.only_if, not_if: config.not_if)

    logger.trace { "Guard: #{guard.should_run?} Runs: #{config.run} on_start: #{config.on_start?}" }

    if config.enabled
      rule = Rule.new(name: config.name, run_queue: config.run_queue, guard: guard, between: config.between)
      rule.set_triggers(config.triggers)
      am = $scriptExtension.get('automationManager')
      am.addRule(rule)
      rule.execute(nil, nil) if config.on_start?
    else
      logger.debug "#{name} marked as disabled, not creating rule."
    end
  end

  class Rule < Java::OrgOpenhabCoreAutomationModuleScriptRulesupportSharedSimple::SimpleRule
    include Actions
    include Logging
    include OpenHAB::Core::DSL::Tod

    using OpenHAB::Core::DSL::Tod::TimeOfDayRange

    def initialize(name:, run_queue:, guard:, between:)
      super()
      setName(name)
      @run_queue = run_queue
      @guard = guard
      @between = between || OpenHAB::Core::DSL::Tod::TimeOfDayRange::ALL_DAY
    end

    def execute(mod, inputs)
      if @guard.should_run?
        now = TimeOfDay.now
        if @between.cover? now
          process_queue(@run_queue.dup, mod, inputs)
        else
          logger.trace("Skipped execution of rule #{name} because the current time #{now} is not between #{@between.begin} and #{@between.end}")
        end
      else
        logger.trace("Skipped execution of rule #{name} because of guard #{@guard}")
      end
    end

    def process_queue(run_queue, mod, inputs)
      while (task = run_queue.shift)
        case task
        when RuleConfig::Run

          event = inputs&.dig('event')

          logger.trace { "Executing rule '#{name}' Run block with event(#{event})" }
          task.block.call(event)
        when RuleConfig::Trigger

          triggering_item = $ir.get(inputs&.dig('event')&.itemName)

          logger.trace { "Executing rule '#{name}' Item Block with item (#{triggering_item})" }
          task.block.call(triggering_item) if triggering_item

        when RuleConfig::Delay
          remaining_queue = run_queue.slice!(0, run_queue.length)
          after(task.duration) { process_queue(remaining_queue, mod, inputs) }
        end
      end
    end
  end
end
