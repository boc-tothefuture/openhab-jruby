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
        #
        # @return [Trigger] Trigger for updated entity
        #
        def updated(*items, to: nil, attach: nil)
          separate_groups(items).map do |item|
            logger.trace("Creating updated trigger for item(#{item}) to(#{to})")
            [to].flatten.map do |to_state|
              update_trigger(item: item, to: to_state, attach: attach)
            end
          end.flatten
        end

        private

        #
        # Create the trigger
        #
        # @param [Object] item item to create trigger for
        # @param [Item State] from state to restrict trigger to
        # @param [Item State] to state to restrict trigger to
        # @param attach attachment
        #
        # @return [Trigger] OpenHAB triggers
        #
        def update_trigger(item:, to:, attach:)
          case to
          when Range then create_update_range_trigger(item: item, to: to, attach: attach)
          when Proc then create_update_proc_trigger(item: item, to: to, attach: attach)
          else create_update_trigger(item: item, to: to, attach: attach)
          end
        end

        #
        # Creates a trigger with a range condition on the 'to' field
        # @param [Object] item to create changed trigger on
        # @param [Object] to state restrict trigger to
        # @param [Object] attach to trigger
        # @return [Trigger] OpenHAB trigger
        #
        def create_update_range_trigger(item:, to:, attach:)
          to, * = Conditions::Proc.range_procs(to)
          create_update_proc_trigger(item: item, to: to, attach: attach)
        end

        #
        # Creates a trigger with a proc condition on the 'to' field
        # @param [Object] item to create changed trigger on
        # @param [Object] to state restrict trigger to
        # @param [Object] attach to trigger
        # @return [Trigger] OpenHAB trigger
        #
        def create_update_proc_trigger(item:, to:, attach:)
          create_update_trigger(item: item, to: nil, attach: attach).tap do |trigger|
            @trigger_conditions[trigger.id] = Conditions::Proc.new(to: to)
          end
        end

        #
        # Create a trigger for updates
        #
        # @param [Object] item Type of item [Group,Thing,Item] to create update trigger for
        # @param [State] to_state state restriction on trigger
        #
        # @return [Trigger] OpenHAB triggers
        #
        def create_update_trigger(item:, to:, attach:)
          trigger, config = case item
                            when OpenHAB::DSL::Items::GroupItem::GroupMembers then group_update(item: item, to: to)
                            when Thing then thing_update(thing: item, to: to)
                            else item_update(item: item, to: to)
                            end
          append_trigger(trigger, config, attach: attach)
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
        def item_update(item:, to:)
          config = { 'itemName' => item.name }
          config['state'] = to.to_s unless to.nil?
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
        def group_update(item:, to:)
          config = { 'groupName' => item.group.name }
          config['state'] = to.to_s unless to.nil?
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
        def thing_update(thing:, to:)
          trigger_for_thing(thing, Trigger::THING_UPDATE, to)
        end
      end
    end
  end
end
