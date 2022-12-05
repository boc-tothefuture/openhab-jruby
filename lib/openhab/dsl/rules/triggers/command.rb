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
          #
          # Create a received command trigger
          #
          # @param [Object] item item to create trigger for
          # @param [Object] command to check against
          # @param [Object] attach object to be attached to the trigger
          #
          # @return [org.openhab.core.automation.Trigger]
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
          # @param [Range] command to restrict trigger to
          # @param [Object] attach object to be attached to the trigger
          # @return [org.openhab.core.automation.Trigger]
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
          # @return [org.openhab.core.automation.Trigger]
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
          # @return [org.openhab.core.automation.Trigger]
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
          # @param [GroupItem::Members] group to create trigger for
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
