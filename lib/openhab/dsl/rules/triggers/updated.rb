# frozen_string_literal: true

require 'openhab/log/logger'
require_relative 'trigger'

module OpenHAB
  module DSL
    module Rules
      #
      # Module holds rule triggers
      #
      module Triggers
        include OpenHAB::Log

        #
        # Create a trigger when item, group or thing is updated
        #
        # @param [Array] items array to trigger on updated
        # @param [State] to to match for tigger
        # @param [Object] attach object to be attached to the trigger
        #
        # @return [Trigger] Trigger for updated entity
        #
        def updated(*items, to: nil, attach: nil)
          updated = Updated.new(rule_triggers: @rule_triggers)
          flattened_items = Updated.flatten_items(items)
          @ruby_triggers << [:updated, flattened_items, { to: to }]
          flattened_items.map do |item|
            logger.trace("Creating updated trigger for item(#{item}) to(#{to})")
            [to].flatten.map do |to_state|
              updated.trigger(item: item, to: to_state, attach: attach)
            end
          end.flatten
        end

        #
        # Creates updated triggers
        #
        class Updated < Trigger
          include OpenHAB::Log

          #
          # Create the trigger
          #
          # @param [Object] item item to create trigger for
          # @param [Item State] to state to restrict trigger to
          # @param [Object] attach object to be attached to the trigger
          #
          # @return [Trigger] OpenHAB triggers
          #
          def trigger(item:, to:, attach:)
            case to
            when Range then range_trigger(item: item, to: to, attach: attach)
            when Proc then proc_trigger(item: item, to: to, attach: attach)
            else update_trigger(item: item, to: to, attach: attach)
            end
          end

          private

          # @return [String] A thing status update trigger
          THING_UPDATE = 'core.ThingStatusUpdateTrigger'

          # @return [String] An item state update trigger
          ITEM_STATE_UPDATE = 'core.ItemStateUpdateTrigger'

          # @return [String] A group state update trigger for items in the group
          GROUP_STATE_UPDATE = 'core.GroupStateUpdateTrigger'

          #
          # Creates a trigger with a range condition on the 'to' field
          # @param [Object] item to create changed trigger on
          # @param [Object] to state restrict trigger to
          # @param [Object] attach object to be attached to the trigger
          # @return [Trigger] OpenHAB trigger
          #
          def range_trigger(item:, to:, attach:)
            to, * = Conditions::Proc.range_procs(to)
            proc_trigger(item: item, to: to, attach: attach)
          end

          #
          # Creates a trigger with a proc condition on the 'to' field
          # @param [Object] item to create changed trigger on
          # @param [Object] to state restrict trigger to
          # @param [Object] attach object to be attached to the trigger
          # @return [Trigger] OpenHAB trigger
          #
          def proc_trigger(item:, to:, attach:)
            conditions = Conditions::Proc.new(to: to)
            update_trigger(item: item, to: nil, attach: attach, conditions: conditions)
          end

          #
          # Create a trigger for updates
          #
          # @param [Object] item Type of item [Group,Thing,Item] to create update trigger for
          # @param [State] to state restriction on trigger
          # @param [Object] attach object to be attached to the trigger
          #
          # @return [Trigger] OpenHAB triggers
          #
          def update_trigger(item:, to:, attach: nil, conditions: nil)
            type, config = case item
                           when OpenHAB::DSL::Items::GroupItem::GroupMembers then group_update(item: item, to: to)
                           when Thing then thing_update(thing: item, to: to)
                           else item_update(item: item, to: to)
                           end
            append_trigger(type: type, config: config, attach: attach, conditions: conditions)
          end

          #
          # Create an update trigger for an item
          #
          # @param [Item] item to create trigger for
          # @param [State] to optional state restriction for target
          #
          # @return [Array<Hash,String>] first element is a String specifying trigger type
          #  second element is a Hash configuring trigger
          #
          def item_update(item:, to:)
            config = { 'itemName' => item.name }
            config['state'] = to.to_s unless to.nil?
            [ITEM_STATE_UPDATE, config]
          end

          #
          # Create an update trigger for a group
          #
          # @param [Item] item to create trigger for
          # @param [State] to optional state restriction for target
          #
          # @return [Array<Hash,String>] first element is a String specifying trigger type
          #  second element is a Hash configuring trigger
          #
          def group_update(item:, to:)
            config = { 'groupName' => item.group.name }
            config['state'] = to.to_s unless to.nil?
            [GROUP_STATE_UPDATE, config]
          end

          #
          # Create an update trigger for a thing
          #
          # @param [Thing] thing to create trigger for
          # @param [State] to optional state restriction for target
          #
          # @return [Array<Hash,String>] first element is a String specifying trigger type
          #  second element is a Hash configuring trigger
          #
          def thing_update(thing:, to:)
            trigger_for_thing(thing: thing, type: THING_UPDATE, to: to)
          end
        end
      end
    end
  end
end
