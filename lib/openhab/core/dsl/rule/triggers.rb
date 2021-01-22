# frozen_string_literal: true

require 'securerandom'

module OpenHAB
  module Core
    module DSL
      module Rule
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
