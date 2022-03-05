# frozen_string_literal: true

require 'java'
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
        def initialize(config:) # rubocop:disable Metrics/MethodLength
          # Metrics disabled because only setters are called or defaults set.
          super()
          set_name(config.name)
          set_description(config.description)
          set_triggers(config.triggers)
          @run_context = config.caller
          @run_queue = config.run
          @guard = config.guard
          # Convert between to correct range or nil if not set
          between = config.between&.then { between(config.between) }
          @between = between || OpenHAB::DSL::Between::ALL_DAY
          @trigger_conditions = config.trigger_conditions
          @attachments = config.attachments
        end

        #
        # Execute the rule
        #
        # @param [Map] mod map provided by OpenHAB rules engine
        # @param [Map] inputs map provided by OpenHAB rules engine containing event and other information
        #
        #
        def execute(mod = nil, inputs = nil)
          thread_local(RULE_NAME: name) do
            logger.trace { "Execute called with mod (#{mod&.to_string}) and inputs (#{inputs.inspect})" }
            logger.trace { "Event details #{inputs['event'].inspect}" } if inputs&.key?('event')
            trigger_conditions(inputs).process(mod: mod, inputs: inputs) do
              process_queue(create_queue(inputs), mod, inputs)
            end
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
        # Returns trigger conditions from inputs if it exists
        #
        # @param [Map] inputs map from OpenHAB containing UID
        #
        # @return [Array] Array of trigger conditions that match rule UID
        #
        def trigger_conditions(inputs)
          # Parse this to get the trigger UID:
          # ["72698819-83cb-498a-8e61-5aab8b812623.event", "oldState", "module", \
          #  "72698819-83cb-498a-8e61-5aab8b812623.oldState", "event", "newState",\
          #  "72698819-83cb-498a-8e61-5aab8b812623.newState"]
          @trigger_conditions[trigger_id(inputs)]
        end

        # If an attachment exists for the trigger for this event add it to the event object
        # @param [Object] event Event
        # @param [Hash] inputs Inputs into event
        # @return [Object] Event with attachment added
        #
        def add_attachment(event, inputs)
          attachment = @attachments[trigger_id(inputs)]
          return event unless attachment

          event.attachment = attachment
          event
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
          logger.log_exception(e, name)
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
          logger.log_exception(e, name)
        end

        #
        # Dispatch execution block tasks to different methods
        #
        # @param [OpenHab Event] event that triggered the rule
        # @param [Task] task task containing otherwise block to execute
        #
        def process_task(event, task)
          thread_local(RULE_NAME: name) do
            case task
            when RuleConfig::Run then process_run_task(event, task)
            when RuleConfig::Trigger then process_trigger_task(event, task)
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
