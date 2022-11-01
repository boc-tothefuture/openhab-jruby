# frozen_string_literal: true

require_relative "trigger"

module OpenHAB
  module DSL
    module Rules
      module Triggers
        # @!visibility private
        #
        # Creates command triggers
        #
        class Command < Trigger
          # Combine command and commands into a single array
          #
          # @param [Array] command list of commands to trigger on
          # @param [Array] commands list of commands to trigger on
          #
          # @return [Array] Combined flattened and compacted list of commands
          #
          def self.combine_commands(command:, commands:)
            combined_commands = ([command] | [commands]).flatten

            # If either command or commands has a value and one is nil, we need to remove nil from the array.
            # If it is only now a single nil value, we leave the nil in place, so that we create a trigger
            # That isn't looking for a specific command.
            combined_commands = combined_commands.compact unless combined_commands.all?(&:nil?)
            combined_commands
          end

          #
          # Create a received command trigger
          #
          # @param [Object] item item to create trigger for
          # @param [Object] command to check against
          # @param [Object] attach object to be attached to the trigger
          #
          # @return [Trigger] OpenHAB triggers
          #
          def trigger(item:, command:, attach:)
            case command
            when Range then range_trigger(item: item, command: command, attach: attach)
            when Proc then proc_trigger(item: item, command: command, attach: attach)
            else command_trigger(item: item, command: command, attach: attach)
            end
          end

          #
          # Creates a trigger with a range condition on the 'command' field
          # @param [Object] item to create changed trigger on
          # @param [Object] command to restrict trigger to
          # @param [Object] attach object to be attached to the trigger
          # @return [Trigger] OpenHAB trigger
          #
          def range_trigger(item:, command:, attach:)
            command_range, * = Conditions::Proc.range_procs(command)
            proc_trigger(item: item, command: command_range, attach: attach)
          end

          #
          # Creates a trigger with a proc condition on the 'command' field
          # @param [Object] item to create changed trigger on
          # @param [Object] command to restrict trigger to
          # @param [Object] attach object to be attached to the trigger
          # @return [Trigger] OpenHAB trigger
          #
          def proc_trigger(item:, command:, attach:)
            conditions = Conditions::Proc.new(command: command)
            command_trigger(item: item, command: nil, attach: attach, conditions: conditions)
          end

          #
          # Create a received trigger based on item type
          #
          # @param [Object] item to create trigger for
          # @param [String] command to create trigger for
          # @param [Object] attach object to be attached to the trigger
          #
          def command_trigger(item:, command:, attach: nil, conditions: nil)
            type, config = if item.is_a?(GroupItem::Members)
                             group(group: item)
                           else
                             item(item: item)
                           end
            config["command"] = command.to_s unless command.nil?
            append_trigger(type: type, config: config, attach: attach, conditions: conditions)
          end

          private

          # @return [String] item command trigger
          ITEM_COMMAND = "core.ItemCommandTrigger"

          # @return [String] A group command trigger for items in the group
          GROUP_COMMAND = "core.GroupCommandTrigger"

          #
          # Create trigger for item commands
          #
          # @param [Item] item to create trigger for
          #
          # @return [Array<Hash,Trigger>] first element is hash of trigger config properties
          #   second element is trigger type
          #
          def item(item:)
            [ITEM_COMMAND, { "itemName" => item.name }]
          end

          #
          # Create trigger for group items
          #
          # @param [Group] group to create trigger for
          #
          # @return [Array<Hash,Trigger>] first element is hash of trigger config properties
          #   second element is trigger type
          #
          def group(group:)
            [GROUP_COMMAND, { "groupName" => group.group.name }]
          end
        end
      end
    end
  end
end
