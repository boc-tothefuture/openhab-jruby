# frozen_string_literal: true

require 'securerandom'
require 'java'

module OpenHAB
  module DSL
    module Rules
      #
      # Module holds rule triggers
      #
      module Triggers
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

        #
        # Append a trigger to the list of triggeres
        #
        # @param [String] type of trigger to create
        # @param [Map] config map describing trigger configuration
        #
        # @return [Trigger] OpenHAB trigger
        #
        def append_trigger(type, config, attach: nil)
          logger.trace("Creating trigger of type #{type} for #{config}")
          config.transform_keys!(&:to_s)
          trigger = Trigger.trigger(type: type, config: config)
          @attachments[trigger.id] = attach if attach
          @triggers << trigger
          trigger
        end

        #
        # Separates groups from items, and flattens any nested arrays of items
        #
        # @param [Array] item_array Array of items passed to a trigger
        #
        # @return [Array] A new flat array with any GroupMembers object left intact
        #
        def separate_groups(item_array)
          # we want to support anything that can be flattened... i.e. responds to to_ary
          # we want to be more lenient than only things that are currently Array,
          # but Enumerable is too lenient because Array#flatten won't traverse interior
          # Enumerables
          return item_array unless item_array.find { |item| item.respond_to?(:to_ary) }

          groups, items = item_array.partition { |item| item.is_a?(OpenHAB::DSL::Items::GroupItem::GroupMembers) }
          groups + separate_groups(items.flatten(1))
        end

        #
        # Class for creating and managing triggers
        #
        class Trigger
          java_import org.openhab.core.automation.util.TriggerBuilder
          java_import org.openhab.core.config.core.Configuration

          # @return [String] A channel event trigger
          CHANNEL_EVENT = 'core.ChannelEventTrigger'

          # @return [String] A thing status Change trigger
          THING_CHANGE = 'core.ThingStatusChangeTrigger'

          # @return [String] A thing status update trigger
          THING_UPDATE = 'core.ThingStatusUpdateTrigger'

          # @return [String] An item command trigger
          ITEM_COMMAND = 'core.ItemCommandTrigger'

          # @return [String] An item state update trigger
          ITEM_STATE_UPDATE = 'core.ItemStateUpdateTrigger'

          # @return [String] An item state change trigger
          ITEM_STATE_CHANGE = 'core.ItemStateChangeTrigger'

          # @return [String] A group state change trigger for items in the group
          GROUP_STATE_CHANGE = 'core.GroupStateChangeTrigger'

          # @return [String] A group state update trigger for items in the group
          GROUP_STATE_UPDATE = 'core.GroupStateUpdateTrigger'

          # @return [String] A group command trigger for items in the group
          GROUP_COMMAND = 'core.GroupCommandTrigger'

          # @return [String] A time of day trigger
          TIME_OF_DAY = 'timer.TimeOfDayTrigger'

          # @return [String] A cron trigger
          CRON = 'timer.GenericCronTrigger'

          #
          # Create a trigger
          #
          # @param [String] type of trigger
          # @param [Map] config map
          #
          # @return [OpenHAB Trigger] configured by type and supplied config
          #
          def self.trigger(type:, config:)
            TriggerBuilder.create
                          .with_id(uuid)
                          .with_type_uid(type)
                          .with_configuration(Configuration.new(config))
                          .build
          end

          #
          # Generate a UUID for triggers
          #
          # @return [String] UUID
          #
          def self.uuid
            SecureRandom.uuid
          end
        end
      end
    end
  end
end
