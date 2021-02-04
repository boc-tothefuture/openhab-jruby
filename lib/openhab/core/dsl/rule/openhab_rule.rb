# frozen_string_literal: true

require 'java'

module OpenHAB
  module Core
    module DSL
      #
      # Creates and manages OpenHAB Rules
      #
      module Rule
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
          # @param [Config] Rule configuration
          #
          def initialize(config:)
            super()
            set_name(config.name)
            set_description(config.description)
            set_triggers(config.triggers)
            @run_queue = config.run_queue
            @guard = config.guard
            between = config.between&.yield_self { between(config.between) }
            @between = between || OpenHAB::Core::DSL::Tod::ALL_DAY
            # Convert between to correct range or nil if not set
            @trigger_delays = config.trigger_delays
          end

          #
          # Execute the rule
          #
          # @param [Map] mod map provided by OpenHAB rules engine
          # @param [Map] inputs map provided by OpenHAB rules engine containing event and other information
          #
          #
          def execute(mod = nil, inputs = nil)
            logger.trace { "Execute called with mod (#{mod&.to_string}) and inputs (#{inputs&.pretty_inspect}" }
            logger.trace { "Event details #{inputs['event'].pretty_inspect}" } if inputs&.key?('event')
            if trigger_delay inputs
              process_trigger_delay(mod, inputs)
            else
              # If guards are satisfied execute the run type blocks
              # If they are not satisfied, execute the Othewise blocks
              queue = create_queue(inputs)
              process_queue(queue, mod, inputs)
            end
          end

          private

          #
          # Create the run queue based on guards
          #
          # @param [Map] inputs rule inputs
          #
          # @return [Queue] <description>
          #
          def create_queue(inputs)
            case check_guards(event: inputs&.dig('event'))
            when true
              @run_queue.dup
            when false
              @run_queue.dup.grep(RuleConfig::Otherwise)
            end
          end

          #
          # Returns trigger delay from inputs if it exists
          #
          # @param [Map] inputs map from OpenHAB containing UID
          #
          # @return [Array] Array of trigger delays that match rule UID
          #
          def trigger_delay(inputs)
            # Parse this to get the trigger UID:
            # ["72698819-83cb-498a-8e61-5aab8b812623.event", "oldState", "module", \
            #  "72698819-83cb-498a-8e61-5aab8b812623.oldState", "event", "newState",\
            #  "72698819-83cb-498a-8e61-5aab8b812623.newState"]
            @trigger_delays[inputs&.keys&.grep(/\.event$/)&.first&.chomp('.event')]
          end

          #
          # Check if trigger guards prevent rule execution
          #
          # @param [Delay] trigger_delay rules delaying trigger because of
          # @param [Object] old_state previous state of the item, may be nil
          # @param [Object] new_state current state of the item, may be nil
          #
          # @return [Boolean] True if the rule should execute, false if trigger guard prevents execution
          #
          def check_trigger_guards(trigger_delay, old_state, new_state)
            if trigger_delay.from.nil? || trigger_delay.from == old_state
              return true if trigger_delay.to.nil? || trigger_delay.to == new_state

              logger.trace("Skipped execution of rule '#{name}' because to state #{new_state}"\
                                   " does not equal specified state(#{trigger_delay.to})")
            else
              logger.trace("Skipped execution of rule '#{name}' because old state #{old_state}"\
                                   " does not equal specified state(#{trigger_delay.from})")
            end
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
            if check_trigger_guards(trigger_delay, inputs['old_state'], inputs['new_state'])
              logger.trace("Trigger Guards Matched for #{trigger_delay}, delaying rule execution")
              # Add timer and attach timer to delay object, and also state being tracked to so timer can be cancelled if
              #   state changes
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
              return true if @between.cover? now

              logger.trace("Skipped execution of rule '#{name}' because the current time #{now} "\
                                   "is not between #{@between.begin} and #{@between.end}")
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
            event = inputs&.dig('event')

            while (task = run_queue.shift)
              case task
              when RuleConfig::Run then process_run_task(event, inputs, task)
              when RuleConfig::Trigger then process_trigger_task(event, task)
              when RuleConfig::Delay then process_delay_task(inputs, mod, run_queue, task)
              when RuleConfig::Otherwise then process_otherwise_task(event, task)
              end
            end
          end

          #
          # Process an otherwise block
          #
          # @param [OpenHab Event] event that triggered the rule
          # @param [Task] task task containing otherwise block to execute
          #
          #
          def process_otherwise_task(event, task)
            logger.trace { "Executing rule '#{name}' otherwise block with event(#{event})" }
            task.block.call(event)
          end

          #
          # Process delay task
          #
          # @param [Map] inputs Rule trigger inputs
          # @param [Map] mod Rule modes
          # @param [Queue] run_queue Queue of tasks for this rule
          # @param [Delay] task to process
          #
          #
          def process_delay_task(inputs, mod, run_queue, task)
            remaining_queue = run_queue.slice!(0, run_queue.length)
            after(task.duration) { process_queue(remaining_queue, mod, inputs) }
          end

          #
          # Process a task that is caused by a group item
          #
          # @param [Map] event Rule event map
          # @param [Trigger] task to execute
          #
          #
          def process_trigger_task(event, task)
            # rubocop: disable Style/GlobalVars
            triggering_item = $ir.get(event&.itemName)
            # rubocop: enable Style/GlobalVars
            logger.trace { "Executing rule '#{name}' trigger block with item (#{triggering_item})" }
            task.block.call(triggering_item) if triggering_item
          end

          #
          # Process a run task
          #
          # @param [OpenHab Event] event information
          # @param [Map] inputs of rule trigger information
          # @param [Run] task to execute
          #
          #
          def process_run_task(event, inputs, task)
            add_event_item(event, inputs)
            logger.trace { "Executing rule '#{name}' run block with event(#{event})" }
            task.block.call(event)
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
