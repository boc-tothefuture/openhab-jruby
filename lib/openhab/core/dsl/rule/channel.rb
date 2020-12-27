# frozen_string_literal: true

require 'core/log'
require 'openhab/core/dsl/rule/triggers'

module OpenHAB
  module Core
    module DSL
      module Rule
        module Channel
          include Logging

          def channel(*channels, thing: nil, triggered: nil)
            channels.flatten.each do |channel|
              channel = [thing, channel].join(':') if thing
              logger.trace("Creating channel trigger for channel(#{channel}), thing(#{thing}), trigger(#{triggered})")
              [triggered].flatten.each do |trigger|
                config = { 'channelUID' => channel }
                config['event'] = trigger.to_s unless trigger.nil?
                config['channelUID'] = channel
                logger.trace("Creating Change Trigger for #{config}")
                @triggers << Trigger.trigger(type: Trigger::CHANNEL_EVENT, config: config)
              end
            end
          end
        end
      end
    end
  end
end
