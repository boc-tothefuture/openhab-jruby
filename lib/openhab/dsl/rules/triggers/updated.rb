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
        # Create a trigger when item, group or thing is updated
        #
        # @param [Array] items array to trigger on updated
        # @param [State] to to match for tigger
        #
        # @return [Trigger] Trigger for updated entity
        #
        def updated(*items, to: nil)
          separate_groups(items).map do |item|
            logger.trace("Creating updated trigger for item(#{item}) to(#{to})")
            [to].flatten.map do |to_state|
              trigger, config = create_update_trigger(item, to_state)
              append_trigger(trigger, config)
            end
          end.flatten
        end

        private

        #
        # Create a trigger for updates
        #
        # @param [Object] item Type of item [Group,Thing,Item] to create update trigger for
        # @param [State] to_state state restriction on trigger
        #
        # @return [Array<Hash,String>] first element is a String specifying trigger type
        #  second element is a Hash configuring trigger
        #
        def create_update_trigger(item, to_state)
          case item
          when OpenHAB::DSL::Items::GroupItem::GroupMembers then group_update(item, to_state)
          when Thing then thing_update(item, to_state)
          else item_update(item, to_state)
          end
        end

        #
        # Create an update trigger for an item
        #
        # @param [Item] item to create trigger for
        # @param [State] to_state optional state restriction for target
        #
        # @return [Array<Hash,String>] first element is a String specifying trigger type
        #  second element is a Hash configuring trigger
        #
        def item_update(item, to_state)
          config = { 'itemName' => item.name }
          config['state'] = to_state.to_s unless to_state.nil?
          trigger = Trigger::ITEM_STATE_UPDATE
          [trigger, config]
        end

        #
        # Create an update trigger for a group
        #
        # @param [Item] item to create trigger for
        # @param [State] to_state optional state restriction for target
        #
        # @return [Array<Hash,String>] first element is a String specifying trigger type
        #  second element is a Hash configuring trigger
        #
        def group_update(item, to_state)
          config = { 'groupName' => item.group.name }
          config['state'] = to_state.to_s unless to_state.nil?
          trigger = Trigger::GROUP_STATE_UPDATE
          [trigger, config]
        end

        #
        # Create an update trigger for a thing
        #
        # @param [Thing] thing to create trigger for
        # @param [State] to_state optional state restriction for target
        #
        # @return [Array<Hash,String>] first element is a String specifying trigger type
        #  second element is a Hash configuring trigger
        #
        def thing_update(thing, to_state)
          trigger_for_thing(thing, Trigger::THING_UPDATE, to_state)
        end
      end
    end
  end
end
