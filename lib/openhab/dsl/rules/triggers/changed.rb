# frozen_string_literal: true

require_relative "conditions/duration"
require_relative "conditions/proc"
require_relative "trigger"

module OpenHAB
  module DSL
    module Rules
      module Triggers
        # @!visibility private
        #
        # Creates changed triggers
        #
        class Changed < Trigger
          #
          # Create the trigger
          #
          # @param [Object] item item to create trigger for
          # @param [Item State] from state to restrict trigger to
          # @param [Item State] to state to restrict trigger to
          # @param [Duration, nil] duration ruration to delay trigger until to state is met
          # @param [Object] attach object to be attached to the trigger
          #
          # @return [Trigger] OpenHAB triggers
          #
          def trigger(item:, from:, to:, duration:, attach:)
            if duration
              wait_trigger(item: item, from: from, to: to, duration: duration, attach: attach)
            elsif [to, from].grep(Range).any?
              range_trigger(item: item, from: from, to: to, attach: attach)
            elsif [to, from].grep(Proc).any?
              proc_trigger(item: item, from: from, to: to, attach: attach)
            else
              changed_trigger(item: item, from: from, to: to, attach: attach)
            end
          end

          private

          # @return [String] A thing status Change trigger
          THING_CHANGE = "core.ThingStatusChangeTrigger"

          # @return [String] An item state change trigger
          ITEM_STATE_CHANGE = "core.ItemStateChangeTrigger"

          # @return [String] A group state change trigger for items in the group
          GROUP_STATE_CHANGE = "core.GroupStateChangeTrigger"

          #
          # Create a TriggerDelay for for an item or group that is changed for a specific duration
          #
          # @param [Object] item to create trigger delay for
          # @param [Duration] duration to delay trigger for until condition is met
          # @param [Item State] to OpenHAB Item State item or group needs to change to
          # @param [Item State] from OpenHAB Item State item or group needs to be coming from
          # @param [Object] attach object to be attached to the trigger
          #
          # @return [Trigger] OpenHAB trigger
          #
          def wait_trigger(item:, duration:, to: nil, from: nil, attach: nil)
            item_name = item.respond_to?(:name) ? item.name : item.to_s
            logger.trace("Creating Changed Wait Change Trigger for Item(#{item_name}) Duration(#{duration}) " \
                         "To(#{to}) From(#{from}) Attach(#{attach})")
            conditions = Conditions::Duration.new(to: to, from: from, duration: duration)
            changed_trigger(item: item, to: nil, from: nil, attach: attach, conditions: conditions)
          end

          #
          # Creates a trigger with a range condition on either 'from' or 'to' field
          # @param [Object] item to create changed trigger on
          # @param [Object] from state to restrict trigger to
          # @param [Object] to state restrict trigger to
          # @param [Object] attach object to be attached to the trigger
          # @return [Trigger] OpenHAB trigger
          #
          def range_trigger(item:, from:, to:, attach:)
            from, to = Conditions::Proc.range_procs(from, to)
            proc_trigger(item: item, from: from, to: to, attach: attach)
          end

          #
          # Creates a trigger with a proc condition on either 'from' or 'to' field
          # @param [Object] item to create changed trigger on
          # @param [Object] from state to restrict trigger to
          # @param [Object] to state restrict trigger to
          # @param [Object] attach object to be attached to the trigger
          # @return [Trigger] OpenHAB trigger
          #
          def proc_trigger(item:, from:, to:, attach:)
            # swap from/to w/ nil if from/to is a proc
            # rubocop:disable Style/ParallelAssignment
            from_proc, from = from, nil if from.is_a?(Proc)
            to_proc, to = to, nil if to.is_a?(Proc)
            # rubocop:enable Style/ParallelAssignment
            conditions = Conditions::Proc.new(to: to_proc, from: from_proc)
            changed_trigger(item: item, from: from, to: to, attach: attach, conditions: conditions)
          end

          #
          # Create a changed trigger
          #
          # @param [Object] item to create changed trigger on
          # @param [Object] from state to restrict trigger to
          # @param [Object] to state restrict trigger to
          # @param [Object] attach object to be attached to the trigger
          #
          def changed_trigger(item:, from:, to:, attach: nil, conditions: nil)
            type, config = case item
                           when GroupItem::Members
                             group(group: item, from: from, to: to)
                           when Core::Things::Thing,
                                Core::Things::ThingUID
                             thing(thing: item, from: from, to: to)
                           else
                             item(item: item, from: from, to: to)
                           end
            append_trigger(type: type, config: config, attach: attach, conditions: conditions)
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
          def thing(thing:, from:, to:)
            trigger_for_thing(thing: thing, type: THING_CHANGE, to: to, from: from)
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
          def item(item:, from:, to:)
            config = { "itemName" => item.name }
            config["state"] = to.to_s if to
            config["previousState"] = from.to_s if from
            [ITEM_STATE_CHANGE, config]
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
          def group(group:, from:, to:)
            config = { "groupName" => group.name }
            config["state"] = to.to_s if to
            config["previousState"] = from.to_s if from
            [GROUP_STATE_CHANGE, config]
          end
        end
      end
    end
  end
end
