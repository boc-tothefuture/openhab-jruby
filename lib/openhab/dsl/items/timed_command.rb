# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      # Extensions for {GenericItem} to implement timed commands
      #
      # All items have an implicit timer associated with them, enabling to
      # easily set an item into a specific state for a specified duration and
      # then at the expiration of that duration have the item automatically
      # change to another state. These timed commands are reentrant, meaning
      # if the same timed command is triggered while an outstanding timed
      # command exist, that timed command will be rescheduled rather than
      # creating a distinct timed command.
      #
      # Timed commands are initiated by using the 'for:' argument with the
      # command. This is available on both the 'command' method and any
      # command-specific methods, e.g. {SwitchItem#on}.
      #
      # Any update to the timed command state will result in the timer being
      # cancelled. For example, if you have a Switch on a timer and another
      # rule sends OFF or ON to that item the timer will be automatically
      # canceled. Sending a different duration (for:) value for the timed
      # command will reschedule the timed command for that new duration.
      #
      module TimedCommand
        # Stores information about timed commands
        # @!visibility private

        TimedCommandDetails = Struct.new(:item, :command, :was, :duration, :on_expire, :timer, :expired, :cancel_rule,
                                         :rule_uid, keyword_init: true) do
          def expired?
            expired
          end

          def canceled?
            !expired?
          end
        end

        @timed_commands = {}

        class << self
          # @!visibility private
          attr_reader :timed_commands
        end

        Core::Items::GenericItem.prepend(self)

        #
        # Sends command to an item for specified duration, then on timer expiration sends
        # the expiration command to the item
        #
        # @param [Command] command to send to object
        # @param [Duration] for duration for item to be in command state
        # @param [Command] on_expire Command to send when duration expires
        # @param [Proc, nil] block
        #   Optional block to invoke when timer expires. If provided,
        #   `on_expire` is ignored and the block is expected to set the item
        #   to the desired state or carry out some action.
        # @return [self]
        #
        # @example
        #   Switch.command(ON, for: 5.minutes)
        # @example
        #   Switch.on for: 5.minutes
        # @example
        #   Dimmer.on for: 5.minutes, on_expire: 50
        # @example
        #   Dimmer.on(for: 5.minutes) { |event| Dimmer.off if Light.on? }
        def command(command, for: nil, on_expire: nil, &block)
          duration = binding.local_variable_get(:for)
          return super(command) unless duration

          # Timer needs access to rule to disable, rule needs access to timer to cancel.
          # Using a mutex to ensure neither fires before the other is constructed
          semaphore = Mutex.new

          semaphore.synchronize do
            timed_command_details = TimedCommand.timed_commands[self]
            if timed_command_details.nil?
              create_timed_command(command: command, duration: duration,
                                   semaphore: semaphore, on_expire: on_expire, &block)
            else
              logger.trace "Outstanding Timed Command #{timed_command_details} encountered - rescheduling"
              timed_command_details.duration = duration # Capture updated duration
              timed_command_details.timer.reschedule duration
            end
          end

          self
        end

        private

        # Creates a new timed command and places it in the TimedCommand hash
        def create_timed_command(command:, duration:, semaphore:, on_expire:, &block)
          on_expire ||= default_on_expire(command)
          timed_command_details = TimedCommandDetails.new(item: self, command: command, was: state,
                                                          on_expire: on_expire, duration: duration)

          # Send specified command after capturing current state
          command(command)

          timed_command_details.timer = timed_command_timer(timed_command_details, semaphore, &block)
          timed_command_details.cancel_rule = TimedCommandCancelRule.new(timed_command_details, semaphore,
                                                                         &block)
          timed_command_details.rule_uid = Core.automation_manager
                                               .add_rule(timed_command_details.cancel_rule)
                                               .uid
          logger.trace "Created Timed Command #{timed_command_details}"
          TimedCommand.timed_commands[self] = timed_command_details
        end

        # Creates the timer to handle changing the item state when timer expires or invoking user supplied block
        # @param [TimedCommandDetailes] timed_command_details details about the timed command
        # @param [Mutex] semaphore Semaphore to lock on to prevent race condition between rule and timer
        # @return [Timer] Timer
        def timed_command_timer(timed_command_details, semaphore, &block)
          DSL.after(timed_command_details.duration, id: self) do
            semaphore.synchronize do
              logger.trace "Timed command expired - #{timed_command_details}"
              cancel_timed_command_rule(timed_command_details)
              timed_command_details.expired = true
              if block
                logger.trace "Invoking block #{block} after timed command for #{name} expired"
                yield(timed_command_details)
              else
                command(timed_command_details.on_expire)
              end

              TimedCommand.timed_commands.delete(timed_command_details.item)
            end
          end
        end

        # Cancels timed command rule
        # @param [TimedCommandDetailed] timed_command_details details about the timed command
        def cancel_timed_command_rule(timed_command_details)
          logger.trace "Removing rule: #{timed_command_details.rule_uid}"
          Rules.scripted_rule_provider.remove_rule(timed_command_details.rule_uid)
        end

        #
        # The default expire for ON/OFF is their inverse
        #
        def default_on_expire(command)
          case format_type(command)
          when ON then OFF
          when OFF then ON
          else state
          end
        end

        #
        # Rule to cancel timed commands
        #
        # @!visibility private
        class TimedCommandCancelRule < org.openhab.core.automation.module.script.rulesupport.shared.simple.SimpleRule
          def initialize(timed_command_details, semaphore, &block)
            super()
            @semaphore = semaphore
            @timed_command_details = timed_command_details
            @block = block
            # Capture rule name if known
            @thread_locals = ThreadLocal.persist
            set_name("Cancels implicit timer for #{timed_command_details.item.name}")
            set_triggers([Rules::RuleTriggers.trigger(
              type: Rules::Triggers::Changed::ITEM_STATE_CHANGE,
              config: { "itemName" => timed_command_details.item.name,
                        "previousState" => timed_command_details.command.to_s }
            )])
          end

          #
          # Execute the rule
          #
          # @param [Map] _mod map provided by OpenHAB rules engine
          # @param [Map] inputs map provided by OpenHAB rules engine containing event and other information
          #
          #
          # There is no feasible way to break this method into smaller components
          def execute(_mod = nil, inputs = nil)
            @semaphore.synchronize do
              ThreadLocal.thread_local(**@thread_locals) do
                logger.trace "Canceling implicit timer #{@timed_command_details.timer} for "\
                             "#{@timed_command_details.item.name}  because received event #{inputs}"
                @timed_command_details.timer.cancel
                $scriptExtension.get("ruleRegistry").remove(@timed_command_details.rule_uid)
                TimedCommand.timed_commands.delete(@timed_command_details.item)
                if @block
                  logger.trace "Executing user supplied block on timed command cancelation"
                  @block&.call(@timed_command_details)
                end
              end
            end
          end
        end
      end
    end
  end
end
