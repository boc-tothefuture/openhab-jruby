# frozen_string_literal: true

require_relative "conditions/duration"
require_relative "conditions/proc"
require_relative "trigger"

module OpenHAB
  module DSL
    module Rules
      module Triggers
        include Log

        #
        # Creates a trigger when an item, member of a group, or a thing changed states.
        #
        # When the changed element is a {Thing}, the `from` and `to` values will accept symbols and strings,
        # where the symbol matches the [supported status](https://www.openhab.org/docs/concepts/things.html#thing-status).
        #
        # @param [Item, GroupItem::GroupMembers, Thing] items Objects to create trigger for.
        # @param [State, Array<State>, Range, Proc] from
        #   Only execute rule if previous state matches `from` state(s).
        # @param [State, Array<State>, Range, Proc] to State(s) for
        #   Only execute rule if new state matches `to` state(s).
        # @param [OpenHAB::Core::Duration] for
        #   Duration item must remain in the same state before executing the execution blocks.
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example Multiple items can be separated with a comma:
        #   rule "Execute rule when either sensor changed" do
        #     changed FrontMotion_Sensor, RearMotion_Sensor
        #     run { |event| logger.info("Motion detected by #{event.item.name}") }
        #   end
        #
        # @example Group member trigger
        #   rule "Execute rule when member changed" do
        #     changed Sensors.members
        #     run { |event| logger.info("Motion detected by #{event.item.name}") }
        #   end
        #
        # @example `for` parameter can be an Item too:
        #   Alarm_Delay << 20
        #
        #   rule "Execute rule when item is changed for specified duration" do
        #     changed Alarm_Mode, for: Alarm_Delay
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example You can optionally provide `from` and `to` states to restrict the cases in which the rule executes:
        #   rule "Execute rule when item is changed to specific number, from specific number, for specified duration" do
        #     changed Alarm_Mode, from: 8, to: [14,12], for: 12.seconds
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example Works with ranges:
        #   rule "Execute when item changed to a range of numbers, from a range of numbers, for specified duration" do
        #     changed Alarm_Mode, from: 8..10, to: 12..14, for: 12.seconds
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example Works with endless ranges:
        #   rule "Execute rule when item is changed to any number greater than 12"
        #     changed Alarm_Mode, to: (12..)   # Parenthesis required for endless ranges
        #     run { logger.info("Alarm Mode Updated") }
        # end
        #
        # @example Works with procs:
        #   rule "Execute when item state is changed from an odd number, to an even number, for specified duration" do
        #     changed Alarm_Mode, from: proc { |from| from.odd? }, to: proc {|to| to.even? }, for: 12.seconds
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example Works with lambdas:
        #   rule "Execute when item state is changed from an odd number, to an even number, for specified duration" do
        #     changed Alarm_Mode, from: -> from { from.odd? }, to: -> to { to.even? }, for: 12.seconds
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example Works with Things:
        #  rule "Execute rule when thing is changed" do
        #    changed things["astro:sun:home"], :from => :online, :to => :uninitialized
        #    run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
        #  end
        #
        # @example Real World Example
        #   rule "Log (or notify) when an exterior door is left open for more than 5 minutes" do
        #     changed ExteriorDoors.members, to: OPEN, for: 5.minutes
        #     triggered {|door| logger.info("#{door.id} has been left open!") }
        #   end

        def changed(*items, to: nil, from: nil, for: nil, attach: nil)
          changed = Changed.new(rule_triggers: @rule_triggers)
          # for is a reserved word in ruby, so use local_variable_get :for
          duration = binding.local_variable_get(:for)

          flattened_items = Changed.flatten_items(items)
          @ruby_triggers << [:changed, flattened_items, { to: to, from: from, duration: duration }]
          flattened_items.map do |item|
            logger.trace("Creating changed trigger for entity(#{item}), to(#{to}), from(#{from})")

            Changed.each_state(from, to) do |from_state, to_state|
              changed.trigger(item: item, from: from_state, to: to_state, duration: duration, attach: attach)
            end
          end.flatten
        end

        # @!visibility private
        #
        # Creates changed triggers
        #
        class Changed < Trigger
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
          def self.each_state(from, to)
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
          # @param [OpenHAB::Core::Duration] duration to delay trigger for until condition is met
          # @param [Item State] to OpenHAB Item State item or group needs to change to
          # @param [Item State] from OpenHAB Item State item or group needs to be coming from
          # @param [Object] attach object to be attached to the trigger
          #
          # @return [Trigger] OpenHAB trigger
          #
          def wait_trigger(item:, duration:, to: nil, from: nil, attach: nil)
            item_name = item.respond_to?(:name) ? item.name : item.to_s
            logger.trace("Creating Changed Wait Change Trigger for Item(#{item_name}) Duration(#{duration}) "\
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
            from_proc, from = from, nil if from.is_a? Proc
            to_proc, to = to, nil if to.is_a? Proc
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
                           when OpenHAB::DSL::Items::GroupItem::GroupMembers then group(group: item, from: from,
                                                                                        to: to)
                           when Thing then thing(thing: item, from: from, to: to)
                           else item(item: item, from: from, to: to)
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
            config = { "groupName" => group.group.name }
            config["state"] = to.to_s if to
            config["previousState"] = from.to_s if from
            [GROUP_STATE_CHANGE, config]
          end
        end
      end
    end
  end
end
