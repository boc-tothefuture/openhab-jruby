# frozen_string_literal: true

require 'openhab/log/logger'
require 'openhab/dsl/rules/triggers/trigger'

module OpenHAB
  module DSL
    module Rules
      #
      # Channel triggers
      #
      module Triggers
        include OpenHAB::Log

        #
        # Creates a channel trigger
        #
        # @param [String, Channel, ChannelUID, Array<String, Channel, ChannelUID>] channels
        #   channels to create triggers for in form of 'binding_id:type_id:thing_id#channel_id'
        #   or 'channel_id' if thing is provided
        # @param [String, Thing, ThingUID, Array<String, Thing, ThingUID>] thing
        #   thing(s) to create trigger for if not specified with the channel
        # @param [String, Array<String>] triggered specific triggering condition(s) to match for trigger
        #
        def channel(*channels, thing: nil, triggered: nil, attach: nil) # rubocop:disable Metrics/AbcSize
          channels.flatten.product([thing].flatten).each do |(channel, t)|
            channel = channel.uid if channel.is_a?(org.openhab.core.thing.Channel)
            t = t.uid if t.is_a?(Thing)
            channel = [t, channel].compact.join(':')
            logger.trace("Creating channel trigger for channel(#{channel}), thing(#{t}), trigger(#{triggered})")
            [triggered].flatten.each do |trigger|
              create_channel_trigger(channel, trigger, attach)
            end
          end
        end

        private

        #
        # Create a trigger for a channel
        #
        # @param [String] channel to look for triggers
        # @param [String] trigger specific channel trigger to match
        #
        #
        def create_channel_trigger(channel, trigger, attach)
          config = { 'channelUID' => channel }
          config['event'] = trigger.to_s unless trigger.nil?
          logger.trace("Creating Change Trigger for #{config}")
          append_trigger(Trigger::CHANNEL_EVENT, config, attach: attach)
        end
      end
    end
  end
end
