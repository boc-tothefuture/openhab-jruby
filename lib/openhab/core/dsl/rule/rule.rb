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

module OpenHAB
  module Core
    module DSL
      module Rule
        class RuleConfig
          include EntityLookup
          include OpenHAB::Core::DSL::Rule::Cron
          include Guard
          include Item
          include Items
          include DSLProperty
          include Actions
          include Logging

          java_import org.openhab.core.library.items.SwitchItem

          attr_reader :triggers, :trigger_delays

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
            @trigger_delays = {}
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

          logger.trace { "Triggers: #{config.triggers} Guard: #{guard.should_run?} Runs: #{config.run} on_start: #{config.on_start?}" }
          config.triggers.each { |trigger| logger.trace { "Trigger UID: #{trigger.id}" } }
          logger.trace { "Trigger Waits #{config.trigger_delays}" }

          if config.enabled
            rule = Rule.new(name: config.name, run_queue: config.run_queue, guard: guard, between: config.between, trigger_delays: config.trigger_delays)
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
          java_import java.time.ZonedDateTime

          using OpenHAB::Core::DSL::Tod::TimeOfDayRange

          def initialize(name:, run_queue:, guard:, between:, trigger_delays:)
            super()
            setName(name)
            @run_queue = run_queue
            @guard = guard
            @between = between || OpenHAB::Core::DSL::Tod::TimeOfDayRange::ALL_DAY
            @trigger_delays = trigger_delays
          end

          # Returns trigger delay from inputs if it exists
          def trigger_delay(inputs)
            # Parse this to get the trigger UID
            # ["72698819-83cb-498a-8e61-5aab8b812623.event", "oldState", "module", "72698819-83cb-498a-8e61-5aab8b812623.oldState", "event", "newState", "72698819-83cb-498a-8e61-5aab8b812623.newState"
            @trigger_delays[inputs&.keys&.grep(/\.event$/)&.first&.chomp('.event')]
          end

          def check_trigger_guards(trigger_delay, inputs)
            old_state = inputs['oldState']
            new_state = inputs['newState']
            if trigger_delay.from.nil? || trigger_delay.from == old_state
              if trigger_delay.to.nil? || trigger_delay.to == new_state
                return true
              else
                logger.trace("Skipped execution of rule #{name} because to state #{new_state} does not equal specified state(#{trigger_delay.to})")
              end
            else
              logger.trace("Skipped execution of rule #{name} because old state #{old_state} does not equal specified state(#{trigger_delay.from})")
            end
            false
          end

          def process_trigger_delay(mod, inputs)
            trigger_delay = trigger_delay(inputs)
            if check_trigger_guards(trigger_delay, inputs)
              logger.trace("Trigger Guards Matched for #{trigger_delay}, delaying rule execution")
              # Add timer and attach timer to delay object, and also state being tracked to so timer can be cancelled if state changes
              # Also another timer should not be created if changed to same value again but instead rescheduled
              if trigger_delay.timer.nil? || trigger_delay.timer.is_active == false
                logger.trace("Creating timer for rule #{name} and trigger delay #{trigger_delay}")
                trigger_delay.timer = after(trigger_delay.duration) do
                  logger.trace("Delay Complete for #{trigger_delay}, executing rule")
                  trigger_delay.timer = nil
                  process_queue(@run_queue.dup, mod, inputs)
                end
                trigger_delay.tracking_to = inputs['newState']
              else
                # Timer active
                state = inputs['newState']
                if state != trigger_delay.tracking_to
                  logger.trace("Item changed to #{state} for #{trigger_delay}, cancelling timer.")
                  trigger_delay.timer.cancel
                  # Reprocess trigger delay after cancelling to track new state (if guards matched, etc)
                  process_trigger_delay(mod, inputs)
                else
                  logger.trace("Item changed to #{state} for #{trigger_delay}, rescheduling timer.")
                  trigger_delay.timer.reschedule(ZonedDateTime.now.plus(Java::JavaTime::Duration.ofMillis(duration.to_ms)))
                end
              end
            else
              logger.trace("Trigger Guards did not match for #{trigger_delay}, ignoring trigger.")
            end
          end

          def execute(mod, inputs)
            logger.trace("Execute called with mod #{mod} and inputs #{inputs}")
            if trigger_delay inputs
              process_trigger_delay(mod, inputs)
            elsif check_guards
              process_queue(@run_queue.dup, mod, inputs)
            end
          end

          def check_guards
            if @guard.should_run?
              now = TimeOfDay.now
              if @between.cover? now
                return true
              else
                logger.trace("Skipped execution of rule #{name} because the current time #{now} is not between #{@between.begin} and #{@between.end}")
              end
            else
              logger.trace("Skipped execution of rule #{name} because of guard #{@guard}")
            end
            false
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
    end
  end
end
