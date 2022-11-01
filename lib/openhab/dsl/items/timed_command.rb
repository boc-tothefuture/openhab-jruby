# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      # Module enables timed commands e.g. Switch.on for: 3.minutes
      module TimedCommand
        # Stores information about timed commands
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
          attr_reader :timed_commands
        end

        # Extensions for {Core::Items::GenericItem} to implement timed commands
        module GenericItem
          Core::Items::GenericItem.prepend(self)

          #
          #  Sends command to an item for specified duration, then on timer expiration sends
          #  the expiration command to the item
          #
          # @param [Types::Type] command to send to object
          # @param [java.time.Duration] for duration for item to be in command state
          # @param [Types::Type] on_expire Command to send when duration expires
          #
          #
          # The mutex makes this over 10 lines, but there is usable way to break this method up
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
          # There is no feasible way to break this method into smaller components
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
          # There is no feasible way to break this method into smaller components
          def timed_command_timer(timed_command_details, semaphore, &block)
            DSL.after(timed_command_details.duration, id: self) do
              semaphore.synchronize do
                logger.trace "Timed command expired - #{timed_command_details}"
                cancel_timed_command_rule(timed_command_details)
                timed_command_details.expired = true
                if block
                  logger.trace "Invoking block #{block} after timed command for #{id} expired"
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
            Rules::Rule.registry.remove(timed_command_details.rule_uid)
          end

          #
          # The default expire for ON/OFF is their inverse
          #
          def default_on_expire(command)
            case format_type_pre(command)
            when ON then OFF
            when OFF then ON
            else state
            end
          end

          #
          # Rule to cancel timed commands
          #
          class TimedCommandCancelRule < org.openhab.core.automation.module.script.rulesupport.shared.simple.SimpleRule
            def initialize(timed_command_details, semaphore, &block)
              super()
              @semaphore = semaphore
              @timed_command_details = timed_command_details
              @block = block
              # Capture rule name if known
              @thread_locals = if Thread.current[:OPENHAB_RULE_UID]
                                 { OPENHAB_RULE_UID: Thread.current[:OPENHAB_RULE_UID] }
                               else
                                 {}
                               end
              set_name("Cancels implicit timer for #{timed_command_details.item.id}")
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
                               "#{@timed_command_details.item.id}  because received event #{inputs}"
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
end
