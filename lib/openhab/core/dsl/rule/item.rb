# frozen_string_literal: true

require 'core/log'
require 'core/dsl/group'
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
            trigger = Trigger.trigger(type: trigger, config: config)
            @triggers << trigger
            @trigger_delays = { trigger.id => TriggerDelay.new(to: to, from: from, duration: duration) }
          end

          def updated(*items, to: nil)
            items.flatten.each do |item|
              logger.trace("Creating updated trigger for item(#{item}) to(#{to})")
              [to].flatten.each do |to_state|
                if item.is_a? GroupItems
                  config = { 'groupName' => item.group.name }
                  trigger = Trigger::GROUP_STATE_UPDATE
                else
                  config = { 'itemName' => item.name }
                  trigger = Trigger::ITEM_STATE_UPDATE
                end
                config['state'] = to_state.to_s unless to_state.nil?
                @triggers << Trigger.trigger(type: trigger, config: config)
              end
            end
          end

          def changed(*items, to: nil, from: nil, for: nil)
            items.flatten.each do |item|
              item = item.group if item.is_a? Group
              logger.trace("Creating changed trigger for item(#{item}), to(#{to}), from(#{from})")
              # for is a reserved word in ruby, so use local_variable_get :for
              if (wait_duration = binding.local_variable_get(:for))
                changed_wait(item, to: to, from: from, duration: wait_duration)
              else
                # Place in array and flatten to support multiple to elements or single or nil
                [to].flatten.each do |to_state|
                  if item.is_a? GroupItems
                    config = { 'groupName' => item.group.name }
                    trigger = Trigger::GROUP_STATE_CHANGE
                  else
                    config = { 'itemName' => item.name }
                    trigger = Trigger::ITEM_STATE_CHANGE
                  end
                  config['state'] = to_state.to_s unless to_state.nil?
                  config['previousState'] = from.to_s unless from.nil?
                  logger.trace("Creating Change Trigger for #{config}")
                  @triggers << Trigger.trigger(type: trigger, config: config)
                end
              end
            end
          end
        end
      end
    end
  end
end
