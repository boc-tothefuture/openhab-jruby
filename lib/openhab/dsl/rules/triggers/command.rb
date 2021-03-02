# frozen_string_literal: true

require 'openhab/log/logger'

module OpenHAB
  module DSL
    module Rules
      #
      # Module holds rule triggers
      #
      module Triggers
        include OpenHAB::Log

        #
        # Create a trigger for when an item or group receives a command
        #
        # The commands/commands parameters are replicated for DSL fluency
        #
        # @param [Array] items Array of items to create trigger for
        # @param [Array] command commands to match for trigger
        # @param [Array] commands commands to match for trigger
        #
        #
        def received_command(*items, command: nil, commands: nil)
          separate_groups(items).flatten.each do |item|
            logger.trace("Creating received command trigger for item(#{item})"\
                         "command(#{command}) commands(#{commands})")

            # Combine command and commands, doing union so only a single nil will be in the combined array.
            combined_commands = combine_commands(command, commands)
            create_received_trigger(combined_commands, item)
          end
        end

        private

        #
        # Create a received trigger based on item type
        #
        # @param [Array] commands to create trigger for
        # @param [Object] item to create trigger for
        #
        #
        def create_received_trigger(commands, item)
          commands.each do |command|
            if item.is_a? OpenHAB::DSL::Items::GroupItem::GroupMembers
              config, trigger = create_group_command_trigger(item)
            else
              config, trigger = create_item_command_trigger(item)
            end
            config['command'] = command.to_s unless command.nil?
            append_trigger(trigger, config)
          end
        end

        #
        # Create trigger for item commands
        #
        # @param [Item] item to create trigger for
        #
        # @return [Array<Hash,Trigger>] first element is hash of trigger config properties
        #   second element is trigger type
        #
        def create_item_command_trigger(item)
          config = { 'itemName' => item.name }
          trigger = Trigger::ITEM_COMMAND
          [config, trigger]
        end

        #
        # Create trigger for group items
        #
        # @param [Group] group to create trigger for
        #
        # @return [Array<Hash,Trigger>] first element is hash of trigger config properties
        #   second element is trigger type
        #
        def create_group_command_trigger(group)
          config = { 'groupName' => group.group.name }
          trigger = Trigger::GROUP_COMMAND
          [config, trigger]
        end

        #
        # Combine command and commands into a single array
        #
        # @param [Array] command list of commands to trigger on
        # @param [Array] commands list of commands to trigger on
        #
        # @return [Array] Combined flattened and compacted list of commands
        #
        def combine_commands(command, commands)
          combined_commands = ([command] | [commands]).flatten

          # If either command or commands has a value and one is nil, we need to remove nil from the array.
          # If it is only now a single nil value, we leave the nil in place, so that we create a trigger
          # That isn't looking for a specific command.
          combined_commands = combined_commands.compact unless combined_commands.all?(&:nil?)
          combined_commands
        end
      end
    end
  end
end
