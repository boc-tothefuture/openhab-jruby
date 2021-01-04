# frozen_string_literal: true

require 'securerandom'

module OpenHAB
  module Core
    module DSL
      module Rule
        # Class for creating triggers
        class Trigger
          java_import org.openhab.core.automation.util.TriggerBuilder
          java_import org.openhab.core.config.core.Configuration

          CHANNEL_EVENT = 'core.ChannelEventTrigger'

          THING_CHANGE = 'core.ThingStatusChangeTrigger'
          THING_UPDATE = 'core.ThingStatusUpdateTrigger'

          ITEM_COMMAND = 'core.ItemCommandTrigger'
          ITEM_STATE_UPDATE = 'core.ItemStateUpdateTrigger'
          ITEM_STATE_CHANGE = 'core.ItemStateChangeTrigger'

          GROUP_STATE_CHANGE = 'core.GroupStateChangeTrigger'
          GROUP_STATE_UPDATE = 'core.GroupStateUpdateTrigger'
          GROUP_COMMAND = 'core.GroupCommandTrigger'

          TIME_OF_DAY = 'timer.TimeOfDayTrigger'
          CRON = 'timer.GenericCronTrigger'

          def self.trigger(type:, config:)
            TriggerBuilder.create
                          .with_id(uuid)
                          .with_type_uid(type)
                          .with_configuration(Configuration.new(config))
                          .build
          end

          def self.uuid
            SecureRandom.uuid
          end
        end
      end
    end
  end
end
