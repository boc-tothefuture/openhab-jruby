# frozen_string_literal: true

require 'openhab/log/logger'
require_relative 'conditions/duration'
require_relative 'conditions/range'

module OpenHAB
  module DSL
    module Rules
      #
      # Module for changed triggers
      #

      module Triggers
        include OpenHAB::Log

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
        def changed(*items, to: nil, from: nil, for: nil, attach: nil)
          separate_groups(items).map do |item|
            logger.trace("Creating changed trigger for entity(#{item}), to(#{to}), from(#{from})")

            # for is a reserved word in ruby, so use local_variable_get :for
            wait_duration = binding.local_variable_get(:for)

            each_state(from, to) do |from_state, to_state|
              changed_trigger(item, from_state, to_state, wait_duration, attach)
            end
          end.flatten
        end

        private

        #
        # Run block for each state combination
        #
        # @param [Item State, Array<Item State>] from state to restrict trigger to
        # @param [Item State, Array<Item State>] to state to restrict trigger to
        #
        # @yieldparam [Item State] from_state from state
        # @yieldparam [Item State] to_state to state
        #
        # @return [Array] array of block return values
        #
        def each_state(from, to)
          [to].flatten.each_with_object([]) do |to_state, agg|
            [from].flatten.each do |from_state|
              agg.push(yield(from_state, to_state))
            end
          end
        end

        #
        # Create the trigger
        #
        # @param [Object] item item to create trigger for
        # @param [Item State] from state to restrict trigger to
        # @param [Item State] to state to restrict trigger to
        # @param [OpenHAB::Core::Duration, nil] duration ruration to delay trigger until to state is met
        # @param attach attachment
        #
        # @return [Trigger] OpenHAB triggers
        #
        def changed_trigger(item, from, to, duration, attach)
          if duration
            changed_wait(item, from: from, to: to, duration: duration, attach: attach)
          elsif [to, from].grep(Range).any?
            create_changed_range_trigger(item, from: from, to: to, attach: attach)
          else
            create_changed_trigger(item, from, to, attach)
          end
        end

        #
        # Create a TriggerDelay for for an item or group that is changed for a specific duration
        #
        # @param [Object] item to create trigger delay for
        # @param [OpenHAB::Core::Duration] duration to delay trigger for until condition is met
        # @param [Item State] to OpenHAB Item State item or group needs to change to
        # @param [Item State] from OpenHAB Item State item or group needs to be coming from
        # @param [Object] attach to trigger
        #
        # @return [Trigger] OpenHAB trigger
        #
        def changed_wait(item, duration:, to: nil, from: nil, attach: nil)
          trigger = create_changed_trigger(item, nil, nil, attach)
          logger.trace("Creating Changed Wait Change Trigger for #{item}")
          @trigger_conditions[trigger.id] = Conditions::Duration.new(to: to, from: from, duration: duration)
          trigger
        end

        #
        # Creates a trigger with a range condition on either 'from' or 'to' field
        # @param [Object] item to create changed trigger on
        # @param [Object] from state to restrict trigger to
        # @param [Object] to state restrict trigger to
        # @param [Object] attach to trigger
        # @return [Trigger] OpenHAB trigger
        #
        def create_changed_range_trigger(item, from:, to:, attach:)
          # swap range w/ nil if from or to is a range
          from_range, from = from, from_range if from.is_a? Range
          to_range, to = to, to_range if to.is_a? Range
          trigger = create_changed_trigger(item, from, to, attach)
          @trigger_conditions[trigger.id] = Conditions::Range.new(to: to_range, from: from_range)
          trigger
        end

        #
        # Create a changed trigger
        #
        # @param [Object] item to create changed trigger on
        # @param [Object] from state to restrict trigger to
        # @param [Object] to state restrict trigger to
        #
        #
        def create_changed_trigger(item, from, to, attach)
          trigger, config = case item
                            when OpenHAB::DSL::Items::GroupItem::GroupMembers
                              create_group_changed_trigger(item, from, to)
                            when Thing then create_thing_changed_trigger(item, from, to)
                            else create_item_changed_trigger(item, from, to)
                            end
          append_trigger(trigger, config, attach: attach)
        end

        #
        # Create a changed trigger for a thing
        #
        # @param [Thing] thing to detected changed states on
        # @param [String] from state to restrict trigger to
        # @param [String] to state to restrict trigger to
        #
        # @return [Array<Hash,String>] first element is a String specifying trigger type
        #  second element is a Hash configuring trigger
        #
        def create_thing_changed_trigger(thing, from, to)
          trigger_for_thing(thing, Trigger::THING_CHANGE, to, from)
        end

        #
        # Create a changed trigger for an item
        #
        # @param [Item] item to detected changed states on
        # @param [String] from state to restrict trigger to
        # @param [String] to to restrict trigger to
        #
        # @return [Array<Hash,String>] first element is a String specifying trigger type
        #  second element is a Hash configuring trigger
        #
        def create_item_changed_trigger(item, from, to)
          config = { 'itemName' => item.name }
          config['state'] = to.to_s if to
          config['previousState'] = from.to_s if from
          trigger = Trigger::ITEM_STATE_CHANGE
          [trigger, config]
        end

        #
        # Create a changed trigger for group items
        #
        # @param [Group] group to detected changed states on
        # @param [String] from state to restrict trigger to
        # @param [String] to to restrict trigger to
        #
        # @return [Array<Hash,String>] first element is a String specifying trigger type
        #  second element is a Hash configuring trigger
        #
        def create_group_changed_trigger(group, from, to)
          config = { 'groupName' => group.group.name }
          config['state'] = to.to_s if to
          config['previousState'] = from.to_s if from
          trigger = Trigger::GROUP_STATE_CHANGE
          [trigger, config]
        end
      end
    end
  end
end
