# frozen_string_literal: true

module OpenHAB
  module DSL
    module Rules
      #
      # OpenHAB rules engine object
      #
      # @!visibility private
      class AutomationRule < org.openhab.core.automation.module.script.rulesupport.shared.simple.SimpleRule
        field_writer :uid

        #
        # Create a new Rule
        #
        # @param [Config] config Rule configuration
        #
        # Constructor sets a number of variables, no further decomposition necessary
        def initialize(config:)
          # Metrics disabled because only setters are called or defaults set.
          super()
          set_name(config.name)
          set_description(config.description)
          set_tags(to_string_set(config.tags))
          set_triggers(config.triggers)
          self.uid = config.uid
          @run_context = config.caller
          @run_queue = config.run
          @guard = config.guard
          @between = config.between && DSL.between(config.between)
          @trigger_conditions = config.trigger_conditions
          @attachments = config.attachments
          @thread_locals = ThreadLocal.persist
        end

        #
        # Execute the rule
        #
        # @param [Map] mod map provided by OpenHAB rules engine
        # @param [Map] inputs map provided by OpenHAB rules engine containing event and other information
        #
        #
        def execute(mod = nil, inputs = nil)
          @result = nil
          ThreadLocal.thread_local(**@thread_locals) do
            begin # rubocop:disable Style/RedundantBegin
              logger.trace { "Execute called with mod (#{mod&.to_string}) and inputs (#{inputs.inspect})" }
              logger.trace { "Event details #{inputs["event"].inspect}" } if inputs&.key?("event")
              trigger_conditions(inputs).process(mod: mod, inputs: inputs) do
                process_queue(create_queue(inputs), mod, inputs)
              end
            rescue Exception => e
              @run_context.send(:logger).log_exception(e)
            end
          end
          @result
        end

        #
        # Cleanup any resources associated with automation rule
        #
        def cleanup
          @trigger_conditions.each_value(&:cleanup)
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
            @run_queue.dup.grep_v(Builder::Otherwise)
          when false
            @run_queue.dup.grep(Builder::Otherwise)
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
          event = inputs&.dig("event")
          unless event
            event = Struct.new(:event, :attachment, :command).new
            event.command = inputs&.dig("command")
          end
          add_attachment(event, inputs)
        end

        #
        # Get the trigger_id for the trigger that caused the rule creation
        #
        # @return [Hash] Input hash potentially containing trigger id
        #
        def trigger_id(inputs)
          inputs&.dig("module")
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
        # @return [true,false] True if guards says rule should execute, false otherwise
        #
        # Loggging inflates method length
        def check_guards(event:)
          return true if @guard.nil?

          if @guard.should_run? event
            return true if @between.nil?

            now = Time.now
            return true if @between.cover? now

            logger.trace("Skipped execution of rule '#{name}' because the current time #{now} "\
                         "is not between #{@between.begin} and #{@between.end}")
          else
            logger.trace("Skipped execution of rule '#{name}' because of guard #{@guard}")
          end
          false
        end

        #
        # Process the run queue
        #
        # @param [Array] run_queue array of procs of various types to execute
        # @param [Map] mod OpenHAB map object describing rule trigger
        # @param [Map] inputs OpenHAB map object describing rule trigge
        #
        def process_queue(run_queue, mod, inputs)
          event = extract_event(inputs)

          while (task = run_queue.shift)
            if task.is_a?(Builder::Delay)
              process_delay_task(inputs, mod, run_queue, task)
            else
              process_task(inputs, event, task)
            end
          end
        end

        #
        # Dispatch execution block tasks to different methods
        #
        # @param [OpenHab Event] event that triggered the rule
        # @param [Task] task task containing otherwise block to execute
        #
        def process_task(inputs, event, task)
          ThreadLocal.thread_local(**@thread_locals) do
            case task
            when Builder::Run then process_run_task(event, task)
            when Builder::Script then process_script_task(inputs, task)
            when Builder::Trigger then process_trigger_task(event, task)
            when Builder::Otherwise then process_otherwise_task(event, task)
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
          DSL.after(task.duration) { process_queue(remaining_queue, mod, inputs) }
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
        # Process a script task
        #
        # @param [Hash] inputs
        # @param [Script] task to execute
        #
        def process_script_task(inputs, task)
          kwargs = {}
          task.block.parameters.each do |(param_type, name)|
            case param_type
            when :keyreq, :key
              kwargs[name] = inputs[name.to_s] if inputs.key?(name.to_s)
            when :keyrest
              inputs.each do |k, v|
                next if k.include?(".")

                kwargs[k.to_sym] = v
              end
            end
          end
          logger.trace { "Executing script '#{name}' run block with kwargs #{kwargs.inspect}" }
          @result = @run_context.instance_exec(**kwargs, &task.block)
        end

        #
        # Convert the given array to a set of strings.
        # Convert Semantics classes to their simple name
        #
        # @example
        #   to_string_set("tag1", Semantics::LivingRoom)
        #
        # @param tags [Array] An array of strings or Semantics classes
        #
        # @return [Set] A set of strings
        #
        def to_string_set(*tags)
          tags = tags.flatten.map do |tag|
            if tag.respond_to?(:java_class) && tag < org.openhab.core.semantics.Tag
              tag.java_class.simple_name
            else
              tag.to_s
            end
          end
          Set.new(tags)
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
