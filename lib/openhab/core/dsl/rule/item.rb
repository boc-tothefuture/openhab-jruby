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
        module Item
          include Logging
          include OpenHAB::Core::DSL::Rule
          include OpenHAB::Core::DSL::Groups
          include OpenHAB::Core::DSL::Things

          TriggerDelay = Struct.new(:to, :from, :duration, :timer, :tracking_to, keyword_init: true)

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

          def received_command(*items, command: nil, commands: nil)
            items.flatten.each do |item|
              logger.trace("Creating received command trigger for item(#{item}) command(#{command}) commands(#{commands})")

              # Combine command and commands, doing union so only a singel nil will be in the combined array.
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

          def append_trigger(trigger, config)
            logger.trace("Creating trigger of type #{trigger} for #{config}")
            trigger = Trigger.trigger(type: trigger, config: config)
            @triggers << trigger
            trigger
          end

          def trigger_for_thing(thing, trigger, to = nil, from = nil)
            config = { 'thingUID' => thing.uid.to_s }
            config['status'] = trigger_state_from_symbol(to).to_s if to
            config['previousStatus'] = trigger_state_from_symbol(from).to_s if from
            [trigger, config]
          end

          def trigger_state_from_symbol(sym)
            sym.to_s.upcase if (sym.is_a? Symbol) || sym
          end
        end
      end
    end
  end
end
