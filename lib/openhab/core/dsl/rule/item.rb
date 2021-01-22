# frozen_string_literal: true

require 'core/log'
require 'core/dsl/group'
require 'core/dsl/things'
require 'core/dsl/rule/triggers'
require 'openhab/core/dsl/rule/triggers'

module OpenHAB
  module Core
    module DSL
      module Rule
        #
        # Triggers for items in rules
        #
        module Item
          include Logging
          include OpenHAB::Core::DSL::Rule
          include OpenHAB::Core::DSL::Groups
          include OpenHAB::Core::DSL::Things

          #
          # Struct capturing data necessary for a conditional trigger
          #
          TriggerDelay = Struct.new(:to, :from, :duration, :timer, :tracking_to, keyword_init: true)

          #
          # Create a TriggerDelay for for an item or group that is changed for a specific duration
          #
          # @param [Object] item to create trigger delay for
          # @param [OpenHAB::Core::Duration] duration to delay trigger for until condition is met
          # @param [Item State] to OpenHAB Item State item or group needs to change to
          # @param [Item State] from OpenHAB Item State item or group needs to be coming from
          #
          # @return [Array] Array of current TriggerDelay objects
          #
          def changed_wait(item, duration:, to: nil, from: nil)
            # Convert to testing the group if group specified rather than item
            item = item.group if item.is_a? Group

            # If GroupItems specified, use the group state trigger instead
            if item.is_a? GroupItems
              config = { 'groupName' => item.group.name }
              trigger = Trigger::GROUP_STATE_CHANGE
            else
              config = { 'itemName' => item.name }
              trigger = Trigger::ITEM_STATE_CHANGE
            end
            logger.trace("Creating Changed Wait Change Trigger for #{config}")
            trigger = append_trigger(trigger, config)
            @trigger_delays = { trigger.id => TriggerDelay.new(to: to, from: from, duration: duration) }
          end

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
            items.flatten.each do |item|
              logger.trace("Creating received command trigger for item(#{item}) command(#{command}) commands(#{commands})")

              # Combine command and commands, doing union so only a single nil will be in the combined array.
              combined_commands = ([command] | [commands]).flatten

              # If either command or commands has a value and one is nil, we need to remove nil from the array.
              # If it is only now a single nil value, we leave the nil in place, so that we create a trigger
              # That isn't looking for a specific command.
              combined_commands = combined_commands.compact unless combined_commands.all?(&:nil?)

              combined_commands.each do |cmd|
                if item.is_a? GroupItems
                  config = { 'groupName' => item.group.name }
                  trigger = Trigger::GROUP_COMMAND
                else
                  config = { 'itemName' => item.name }
                  trigger = Trigger::ITEM_COMMAND
                end
                config['command'] = cmd.to_s unless cmd.nil?
                append_trigger(trigger, config)
              end
            end
          end

          #
          # Create a trigger when item, group or thing is updated
          #
          # @param [Array] items array to trigger on updated
          # @param [State] to to match for tigger
          #
          # @return [Trigger] Trigger for updated entity
          #
          def updated(*items, to: nil)
            items.flatten.each do |item|
              logger.trace("Creating updated trigger for item(#{item}) to(#{to})")
              [to].flatten.each do |to_state|
                case item
                when GroupItems
                  config = { 'groupName' => item.group.name }
                  config['state'] = to_state.to_s unless to_state.nil?
                  trigger = Trigger::GROUP_STATE_UPDATE
                when Thing
                  trigger, config = trigger_for_thing(item, Trigger::THING_UPDATE, to_state)
                else
                  config = { 'itemName' => item.name }
                  config['state'] = to_state.to_s unless to_state.nil?
                  trigger = Trigger::ITEM_STATE_UPDATE
                end
                append_trigger(trigger, config)
              end
            end
          end

          #
          # Creates a trigger item, group and thing changed
          #
          # @param [Object] items array of objects to create trigger for
          # @param [to] to state for object to change for
          # @param [from] from <description>
          # @param [OpenHAB::Core::Duration] for Duration to delay trigger until to state is met
          #
          # @return [Trigger] OpenHAB trigger
          #
          def changed(*items, to: nil, from: nil, for: nil)
            items.flatten.each do |item|
              item = item.group if item.is_a? Group
              logger.trace("Creating changed trigger for entity(#{item}), to(#{to}), from(#{from})")
              # for is a reserved word in ruby, so use local_variable_get :for
              if (wait_duration = binding.local_variable_get(:for))
                changed_wait(item, to: to, from: from, duration: wait_duration)
              else
                # Place in array and flatten to support multiple to elements or single or nil
                [to].flatten.each do |to_state|
                  case item
                  when GroupItems
                    config = { 'groupName' => item.group.name }
                    config['state'] = to_state.to_s if to_state
                    config['previousState'] = from.to_s if from
                    trigger = Trigger::GROUP_STATE_CHANGE
                  when Thing
                    trigger, config = trigger_for_thing(item, Trigger::THING_CHANGE, to_state, from)
                  else
                    config = { 'itemName' => item.name }
                    config['state'] = to_state.to_s if to_state
                    config['previousState'] = from.to_s if from
                    trigger = Trigger::ITEM_STATE_CHANGE
                  end
                  append_trigger(trigger, config)
                end
              end
            end
          end

          private

          #
          # Append a trigger to the list of triggeres
          #
          # @param [String] type of trigger to create
          # @param [Map] config map describing trigger configuration
          #
          # @return [Trigger] OpenHAB trigger
          #
          def append_trigger(type, config)
            logger.trace("Creating trigger of type #{type} for #{config}")
            trigger = Trigger.trigger(type: type, config: config)
            @triggers << trigger
            trigger
          end

          #
          # Create a trigger for a thing
          #
          # @param [Thing] thing to create trigger for
          # @param [Trigger] trigger to map with thing
          # @param [State] to for thing
          # @param [State] from state of thing
          #
          # @return [Array] Trigger and config for thing
          #
          def trigger_for_thing(thing, trigger, to = nil, from = nil)
            config = { 'thingUID' => thing.uid.to_s }
            config['status'] = trigger_state_from_symbol(to).to_s if to
            config['previousStatus'] = trigger_state_from_symbol(from).to_s if from
            [trigger, config]
          end

          #
          # converts object to upcase string if its a symbol
          #
          # @param [sym] sym potential symbol to convert
          #
          # @return [String] Upcased symbol as string
          #
          def trigger_state_from_symbol(sym)
            sym.to_s.upcase if (sym.is_a? Symbol) || sym
          end
        end
      end
    end
  end
end
