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
    module DSL
      #
      # Creates and manages OpenHAB Rules
      #
      module Rule
        #
        # Rule configuration for OpenHAB Rules engine
        #
        class RuleConfig
          include EntityLookup
          include OpenHAB::Core::DSL::Rule::Cron
          include Guard
          include Item
          include Channel
          include DSLProperty
          include Logging
          extend OpenHAB::Core::DSL

          java_import org.openhab.core.library.items.SwitchItem

          # @return [Array] Of triggers
          attr_reader :triggers

          # @return [Array] Of trigger delays
          attr_reader :trigger_delays

          #
          # Struct holding a run block
          #
          Run = Struct.new(:block)

          #
          # Struct holding a Triggered block
          #
          Trigger = Struct.new(:block)

          #
          # Struct holding an otherwise block
          #
          Otherwise = Struct.new(:block)

          #
          # Struct holding rule delays
          #
          Delay = Struct.new(:duration)

          prop_array :run, array_name: :run_queue, wrapper: Run
          prop_array :triggered, array_name: :run_queue, wrapper: Trigger
          prop_array :delay, array_name: :run_queue, wrapper: Delay
          prop_array :otherwise, array_name: :run_queue, wrapper: Otherwise

          prop :name
          prop :description
          prop :enabled
          prop :between

          #
          # Create a new RuleConfig
          #
          # @param [Object] caller_binding The object initializing this configuration.
          #   Used to execute within the object's context
          #
          def initialize(caller_binding)
            @triggers = []
            @trigger_delays = {}
            @enabled = true
            @on_start = false
            @caller = caller_binding.eval 'self'
          end

          #
          # Start this rule on system startup
          #
          # @param [Boolean] run_on_start Run this rule on start, defaults to True
          #
          #
          def on_start(run_on_start = true)
            @on_start = run_on_start
          end

          #
          # Checks if this rule should run on start
          #
          # @return [Boolean] True if rule should run on start, false otherwise.
          #
          def on_start?
            @on_start
          end

          #
          # Run the supplied block inside the object instance of the object that created the rule config
          #
          # @yield [] Block executed in context of the object creating the rule config
          #
          #
          def my(&block)
            @caller.instance_eval(&block)
          end
        end

        #
        # Create a new rule
        #
        # @param [String] name <description>
        # @yield [] Block executed in context of a RuleConfic
        #
        #
        def rule(name, &block)
          config = RuleConfig.new(block.binding)
          config.name(name)
          config.instance_eval(&block)
          return if !config.on_start? && config.triggers.empty?

          guard = Guard::Guard.new(only_if: config.only_if, not_if: config.not_if)

          logger.trace do
            "Triggers: #{config.triggers} Guard: #{guard} Runs: #{config.run} on_start: #{config.on_start?}"
          end
          config.triggers.each { |trigger| logger.trace { "Trigger UID: #{trigger.id}" } }
          logger.trace { "Trigger Waits #{config.trigger_delays}" }

          if config.enabled
            # Convert between to correct range or nil if not set
            between = config.between&.yield_self { between(config.between) }

            rule = Rule.new(name: config.name, description: config.description, run_queue: config.run_queue,
                            guard: guard, between: between, trigger_delays: config.trigger_delays)

            rule.set_triggers(config.triggers)
            am = $scriptExtension.get('automationManager')
            am.addRule(rule)
            rule.execute(nil, nil) if config.on_start?
          else
            logger.debug "#{name} marked as disabled, not creating rule."
          end
        end

        #
        # JRuby extension to OpenHAB Rule
        #
        class Rule < Java::OrgOpenhabCoreAutomationModuleScriptRulesupportSharedSimple::SimpleRule
          include Logging
          include OpenHAB::Core::DSL::Tod
          java_import java.time.ZonedDateTime

          #
          # Create a new Rule
          #
          # @param [String] name Name of the rule
          # @param [String] description of the rule
          # @param [Array] run_queue array of procs to execute for rule
          # @param [Array] guard array of guards
          # @param [Range] between range in which the rule will execute
          # @param [Array] trigger_delays Array of delays for tiggers based on item config
          #
          def initialize(name:, description:, run_queue:, guard:, between:, trigger_delays:)
            super()
            setName(name)
            setDescription(description)
            @run_queue = run_queue
            @guard = guard
            @between = between || OpenHAB::Core::DSL::Tod::ALL_DAY
            @trigger_delays = trigger_delays
          end

          #
          # Execute the rule
          #
          # @param [Map] mod map provided by OpenHAB rules engine
          # @param [Map] inputs map provided by OpenHAB rules engine containing event and other information
          #
          #
          def execute(mod, inputs)
            logger.trace { "Execute called with mod (#{mod&.to_string}) and inputs (#{inputs&.pretty_inspect}" }
            logger.trace { "Event details #{inputs['event'].pretty_inspect}" } if inputs&.key?('event')
            if trigger_delay inputs
              process_trigger_delay(mod, inputs)
            else
              # If guards are satisfied execute the run type blocks
              # If they are not satisfied, execute the Othewise blocks
              queue = case check_guards(event: inputs&.dig('event'))
                      when true
                        @run_queue.dup
                      when false
                        @run_queue.dup.grep(RuleConfig::Otherwise)
                      end
              process_queue(queue, mod, inputs)
            end
          end

          private

          #
          # Returns trigger delay from inputs if it exists
          #
          # @param [Map] inputs map from OpenHAB containing UID
          #
          # @return [Array] Array of trigger delays that match rule UID
          #
          def trigger_delay(inputs)
            # Parse this to get the trigger UID:
            # ["72698819-83cb-498a-8e61-5aab8b812623.event", "oldState", "module", "72698819-83cb-498a-8e61-5aab8b812623.oldState", "event", "newState", "72698819-83cb-498a-8e61-5aab8b812623.newState"
            @trigger_delays[inputs&.keys&.grep(/\.event$/)&.first&.chomp('.event')]
          end

          #
          # Check if trigger guards prevent rule execution
          #
          # @param [Delay] trigger_delay rules delaying trigger because of
          # @param [Map] inputs map from OpenHAB describing the rle trigger
          #
          # @return [Boolean] True if the rule should execute, false if trigger guard prevents execution
          #
          def check_trigger_guards(trigger_delay, inputs)
            old_state = inputs['oldState']
            new_state = inputs['newState']
            if trigger_delay.from.nil? || trigger_delay.from == old_state
              if trigger_delay.to.nil? || trigger_delay.to == new_state
                return true
              else
                logger.trace("Skipped execution of rule '#{name}' because to state #{new_state} does not equal specified state(#{trigger_delay.to})")
              end
            else
              logger.trace("Skipped execution of rule '#{name}' because old state #{old_state} does not equal specified state(#{trigger_delay.from})")
            end
            false
          end

          #
          # Process any matching trigger delays
          #
          # @param [Map] mod OpenHAB map object describing rule trigger
          # @param [Map] inputs OpenHAB map object describing rule trigge
          #
          #
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
                  trigger_delay.timer.reschedule(ZonedDateTime.now.plus(duration))
                end
              end
            else
              logger.trace("Trigger Guards did not match for #{trigger_delay}, ignoring trigger.")
            end
          end

          #
          # Check if any guards prevent execution
          #
          # @param [Map] event OpenHAB rule trigger event
          #
          # @return [Boolean] True if guards says rule should execute, false otherwise
          #
          def check_guards(event:)
            if @guard.should_run? event
              now = TimeOfDay.now
              if @between.cover? now
                return true
              else
                logger.trace("Skipped execution of rule '#{name}' because the current time #{now} is not between #{@between.begin} and #{@between.end}")
              end
            else
              logger.trace("Skipped execution of rule '#{name}' because of guard #{@guard}")
            end
            false
          end

          #
          # Patch event to include event.item when it doesn't exist
          # This is to patch a bug see https://github.com/boc-tothefuture/openhab-jruby/issues/75
          # It may be fixed in the openhab core in the future, in which case, this patch will no longer be necessary
          #
          # @param [OpenHAB Event] event to check for item accessor
          # @param [OpenHAB Event Inputs] inputs inputs to running rule
          #
          def add_event_item(event, inputs)
            return if event.nil? || defined?(event.item)

            class << event
              attr_accessor :item
            end
            event.item = inputs&.dig('triggeringItem')
          end

          #
          # Process the run queue
          #
          # @param [Array] run_queue array of procs of various types to execute
          # @param [Map] mod OpenHAB map object describing rule trigger
          # @param [Map] inputs OpenHAB map object describing rule trigge
          #
          #
          def process_queue(run_queue, mod, inputs)
            while (task = run_queue.shift)
              case task
              when RuleConfig::Run

                event = inputs&.dig('event')
                add_event_item(event, inputs)
                logger.trace { "Executing rule '#{name}' run block with event(#{event})" }
                task.block.call(event)
              when RuleConfig::Trigger

                triggering_item = $ir.get(inputs&.dig('event')&.itemName)

                logger.trace { "Executing rule '#{name}' trigger block with item (#{triggering_item})" }
                task.block.call(triggering_item) if triggering_item

              when RuleConfig::Delay
                remaining_queue = run_queue.slice!(0, run_queue.length)
                after(task.duration) { process_queue(remaining_queue, mod, inputs) }

              when RuleConfig::Otherwise
                event = inputs&.dig('event')
                logger.trace { "Executing rule '#{name}' otherwise block with event(#{event})" }
                task.block.call(event)

              end
            end
          end

          #
          # Create a new hash in which all elements are converted to strings
          #
          # @param [Map] hash in which all elements should be converted to strings
          #
          # @return [Map] new map with values converted to strings
          #
          def inspect_hash(hash)
            hash.each_with_object({}) do |(key, value), new_hash|
              new_hash[inspect_item(key)] = inspect_item(value)
            end
          end

          #
          # Convert an individual element into a string based on if it a Ruby or Java object
          #
          # @param [Object] item to convert to a string
          #
          # @return [String] representation of item
          #
          def inspect_item(item)
            if item.respond_to? :to_string
              item.to_string
            elsif item.respond_to? :to_str
              item.to_str
            end
          end
        end
      end
    end
  end
end
