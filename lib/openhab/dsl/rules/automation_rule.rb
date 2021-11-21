# frozen_string_literal: true

require 'java'
require 'set'
require 'openhab/core/thread_local'
require 'openhab/log/logger'
require 'openhab/dsl/between'

require_relative 'item_event'

module OpenHAB
  module DSL
    #
    # Creates and manages OpenHAB Rules
    #
    module Rules
      #
      # JRuby extension to OpenHAB Rule
      #
      # rubocop: disable Metrics/ClassLength
      # Disabled because this class has a single responsibility, there does not appear a logical
      # way of breaking it up into multiple classes
      class AutomationRule < Java::OrgOpenhabCoreAutomationModuleScriptRulesupportSharedSimple::SimpleRule
        include OpenHAB::Log
        include OpenHAB::Core::ThreadLocal
        include OpenHAB::DSL::Between
        java_import java.time.ZonedDateTime

        #
        # Create a new Rule
        #
        # @param [Config] config Rule configuration
        #
        # Constructor sets a number of variables, no further decomposition necessary
        # rubocop:disable Metrics/MethodLength
        # Metrics disabled because only setters are called or defaults set.
        def initialize(config:)
          super()
          set_name(config.name)
          set_description(config.description)
          set_triggers(config.triggers)
          @run_context = config.caller
          @run_queue = config.run
          @guard = config.guard
          between = config.between&.yield_self { between(config.between) }
          @between = between || OpenHAB::DSL::Between::ALL_DAY
          # Convert between to correct range or nil if not set
          @trigger_delays = config.trigger_delays
          @attachments = config.attachments
        end
        # rubocop:enable Metrics/MethodLength

        #
        # Execute the rule
        #
        # @param [Map] mod map provided by OpenHAB rules engine
        # @param [Map] inputs map provided by OpenHAB rules engine containing event and other information
        #
        #
        def execute(mod = nil, inputs = nil)
          logger.trace { "Execute called with mod (#{mod&.to_string}) and inputs (#{inputs&.pretty_inspect})" }
          logger.trace { "Event details #{inputs['event'].pretty_inspect}" } if inputs&.key?('event')
          if trigger_delay inputs
            trigger_delay = trigger_delay(inputs)
            process_trigger_delay(trigger_delay, mod, inputs)
          else
            # If guards are satisfied execute the run type blocks
            # If they are not satisfied, execute the Othewise blocks
            queue = create_queue(inputs)
            process_queue(queue, mod, inputs)
          end
        end

        #
        # Cleanup any resources associated with automation rule
        #
        def cleanup
          # No cleanup is necessary right now, trigger delays are tracked and cancelled by timers library
        end

        private

        #
        # Create the run queue based on guards
        #
        # @param [Map] inputs rule inputs
        # @return [Queue] <description>
        #
        def create_queue(inputs)
          case check_guards(event: extract_event(inputs))
          when true
            @run_queue.dup.grep_v(RuleConfig::Otherwise)
          when false
            @run_queue.dup.grep(RuleConfig::Otherwise)
          end
        end

        #
        # Extract the event object from inputs
        # and merge other inputs keys/values into the event
        #
        # @param [Map] inputs rule inputs
        #
        # @return [Object] event object
        #
        def extract_event(inputs)
          event = inputs&.dig('event')
          unless event
            event = Struct.new(:event, :attachment, :command).new
            event.command = inputs&.dig('command')
          end
          add_attachment(event, inputs)
        end

        #
        # Get the trigger_id for the trigger that caused the rule creation
        #
        # @return [Hash] Input hash potentially containing trigger id
        #
        def trigger_id(inputs)
          inputs&.dig('module')
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
          @trigger_delays[trigger_id(inputs)]
        end

        # If an attachment exists for the trigger for this event add it to the event object
        # @param [Object] Event
        # @param [Hash] Inputs into event
        # @return [Object] Event with attachment added
        #
        def add_attachment(event, inputs)
          attachment = @attachments[trigger_id(inputs)]
          return event unless attachment

          event.attachment = attachment
          event
        end

        #
        # Check if trigger guards prevent rule execution
        #
        # @param [Delay] trigger_delay rules delaying trigger because of
        # @param [Map] inputs OpenHAB map object describing rule trigger
        #
        # @return [Boolean] True if the rule should execute, false if trigger guard prevents execution
        #
        def check_trigger_guards(trigger_delay, inputs)
          new_state, old_state = retrieve_states(inputs)
          if check_from(trigger_delay, old_state)
            return true if check_to(trigger_delay, new_state)

            logger.trace("Skipped execution of rule '#{name}' because to state #{new_state}"\
                         " does not equal specified state(#{trigger_delay.to})")
          else
            logger.trace("Skipped execution of rule '#{name}' because old state #{old_state}"\
                         " does not equal specified state(#{trigger_delay.from})")
          end
        end

        #
        # Rerieve the newState and oldState, alternatively newStatus and oldStatus
        # from the input map
        #
        # @param [Map] inputs OpenHAB map object describing rule trigger
        #
        # @return [Array] An array of the values for [newState, oldState] or [newStatus, oldStatus]
        #
        def retrieve_states(inputs)
          old_state = inputs['oldState'] || thing_status_to_sym(inputs['oldStatus'])
          new_state = inputs['newState'] || thing_status_to_sym(inputs['newStatus'])

          [new_state, old_state]
        end

        #
        # Converts a ThingStatus object to a ruby Symbol
        #
        # @param [Java::OrgOpenhabCoreThing::ThingStatus] status A ThingStatus instance
        #
        # @return [Symbol] A corresponding symbol, in lower case
        #
        def thing_status_to_sym(status)
          status&.to_s&.downcase&.to_sym
        end

        #
        # Check the from state against the trigger delay
        #
        # @param [TriggerDelay] trigger_delay Information about the trigger delay
        # @param [Item State] state from state to check
        #
        # @return [Boolean] true if no from state is defined or defined state equals supplied state
        #
        def check_from(trigger_delay, state)
          trigger_delay.from.nil? || state == trigger_delay.from
        end

        #
        # Check the to state against the trigger delay
        #
        # @param [TriggerDelay] trigger_delay Information about the trigger delay
        # @param [Item State] state to-state to check
        #
        # @return [Boolean] true if no to state is defined or defined state equals supplied state
        #
        def check_to(trigger_delay, state)
          trigger_delay.to.nil? || state == trigger_delay.to
        end

        #
        # Process any matching trigger delays
        #
        # @param [Map] mod OpenHAB map object describing rule trigger
        # @param [Map] inputs OpenHAB map object describing rule trigger
        #
        #
        def process_trigger_delay(trigger_delay, mod, inputs)
          if trigger_delay.timer_active?
            process_active_timer(inputs, mod, trigger_delay)
          elsif check_trigger_guards(trigger_delay, inputs)
            logger.trace("Trigger Guards Matched for #{trigger_delay}, delaying rule execution")
            # Add timer and attach timer to delay object, and also state being tracked to so timer can be cancelled if
            #   state changes
            # Also another timer should not be created if changed to same value again but instead rescheduled
            create_trigger_delay_timer(inputs, mod, trigger_delay)
          else
            logger.trace("Trigger Guards did not match for #{trigger_delay}, ignoring trigger.")
          end
        end

        #
        # Creatas a timer for trigger delays
        #
        # @param [Hash] inputs rule trigger inputs
        # @param [Hash] mod rule trigger mods
        # @param [TriggerDelay] trigger_delay specifications
        #
        #
        def create_trigger_delay_timer(inputs, mod, trigger_delay)
          logger.trace("Creating timer for rule #{name} and trigger delay #{trigger_delay}")
          trigger_delay.timer = after(trigger_delay.duration) do
            logger.trace("Delay Complete for #{trigger_delay}, executing rule")
            trigger_delay.timer = nil
            queue = create_queue(inputs)
            process_queue(queue, mod, inputs)
          end
          trigger_delay.tracking_to, = retrieve_states(inputs)
        end

        #
        # Process an active trigger timer
        #
        # @param [Hash] inputs rule trigger inputs
        # @param [Hash] mod rule trigger mods
        # @param [TriggerDelay] trigger_delay specifications
        #
        #
        def process_active_timer(inputs, mod, trigger_delay)
          state, = retrieve_states(inputs)
          if state == trigger_delay.tracking_to
            logger.trace("Item changed to #{state} for #{trigger_delay}, rescheduling timer.")
            trigger_delay.timer.reschedule(ZonedDateTime.now.plus(trigger_delay.duration))
          else
            logger.trace("Item changed to #{state} for #{trigger_delay}, canceling timer.")
            trigger_delay.timer.cancel
            # Reprocess trigger delay after canceling to track new state (if guards matched, etc)
            process_trigger_delay(trigger_delay, mod, inputs)
          end
        end

        #
        # Check if any guards prevent execution
        #
        # @param [Map] event OpenHAB rule trigger event
        #
        # @return [Boolean] True if guards says rule should execute, false otherwise
        #
        # rubocop:disable Metrics/MethodLength
        # Loggging inflates method length
        def check_guards(event:)
          if @guard.should_run? event
            now = Time.now
            return true if @between.cover? now

            logger.trace("Skipped execution of rule '#{name}' because the current time #{now} "\
                         "is not between #{@between.begin} and #{@between.end}")
          else
            logger.trace("Skipped execution of rule '#{name}' because of guard #{@guard}")
          end
          false
        rescue StandardError => e
          print_backtrace(e)
        end
        # rubocop:enable Metrics/MethodLength

        #
        # Process the run queue
        #
        # @param [Array] run_queue array of procs of various types to execute
        # @param [Map] mod OpenHAB map object describing rule trigger
        # @param [Map] inputs OpenHAB map object describing rule trigge
        #
        #
        # No logical way to break this method up
        def process_queue(run_queue, mod, inputs)
          event = extract_event(inputs)

          while (task = run_queue.shift)
            if task.is_a? RuleConfig::Delay
              process_delay_task(inputs, mod, run_queue, task)
            else
              process_task(event, task)
            end
          end
        rescue StandardError => e
          print_backtrace(e)
        end

        #
        # Dispatch execution block tasks to different methods
        #
        # @param [OpenHab Event] event that triggered the rule
        # @param [Task] task task containing otherwise block to execute
        #
        def process_task(event, task)
          case task
          when RuleConfig::Run then process_run_task(event, task)
          when RuleConfig::Trigger then process_trigger_task(event, task)
          when RuleConfig::Otherwise then process_otherwise_task(event, task)
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
          @run_context.instance_exec(event, &task.block)
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
          return unless event&.item

          logger.trace { "Executing rule '#{name}' trigger block with item (#{event.item})" }
          @run_context.instance_exec(event.item, &task.block)
        end

        #
        # Process a run task
        #
        # @param [OpenHab Event] event information
        # @param [Run] task to execute
        #
        #
        def process_run_task(event, task)
          logger.trace { "Executing rule '#{name}' run block with event(#{event})" }
          @run_context.instance_exec(event, &task.block)
        end

        #
        # Print error and stack trace without calls to internal classes
        #
        # @param [Exception] error A rescued error
        #
        def print_backtrace(error)
          error = logger.clean_backtrace(error)
          logger.error { "#{error.message} (#{error.class})\nIn rule: #{name}\n#{error.backtrace&.join("\n")}" }
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
# rubocop: enable Metrics/ClassLength
