# frozen_string_literal: true

require 'openhab/log/logger'
require 'openhab/dsl/things'
require_relative 'trigger'

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
        # @param [Object] attach object to be attached to the trigger
        #
        def channel(*channels, thing: nil, triggered: nil, attach: nil)
          channel_trigger = Channel.new(rule_triggers: @rule_triggers)
          Channel.channels(channels: channels, thing: thing).each do |channel|
            [triggered].flatten.each do |trigger|
              channel_trigger.trigger(channel: channel, trigger: trigger, attach: attach)
            end
          end
        end

        #
        # Creates channel triggers
        #
        class Channel < Trigger
          include OpenHAB::Log

          # @return [String] A channel event trigger
          CHANNEL_EVENT = 'core.ChannelEventTrigger'

          #
          # Get an enumerator over the product of the channels and things and map them to a channel id
          # @param [Object] channels to iterate over
          # @param [Object] thing to combine with channels and iterate over
          # @return [Enumerable] enumerable channel ids to trigger on
          def self.channels(channels:, thing:)
            logger.state 'Creating Channel/Thing Pairs', channels: channels, thing: thing
            channels.flatten.product([thing].flatten)
                    .map { |channel_thing| channel_id(*channel_thing) }
          end

          #
          # Get a channel id from a channel and thing
          # @param [Object] channel part of channel id, get UID if object is a Channel
          # @param [Object] thing part of channel id, get UID if object is a Thing
          #
          def self.channel_id(channel, thing)
            channel = channel.uid if channel.is_a?(org.openhab.core.thing.Channel)
            thing = thing.uid if thing.is_a?(Thing)
            [thing, channel].compact.join(':')
          end

          #
          # Create a trigger for a channel
          #
          # @param [String] channel to look for triggers
          # @param [String] trigger specific channel trigger to match
          # @param [Object] attach object to be attached to the trigger
          #
          #
          def trigger(channel:, trigger:, attach:)
            config = { 'channelUID' => channel }
            config['event'] = trigger.to_s unless trigger.nil?
            logger.state 'Creating Channel Trigger', channel: channel, config: config
            append_trigger(type: CHANNEL_EVENT, config: config, attach: attach)
          end
        end
      end
    end
  end
end
