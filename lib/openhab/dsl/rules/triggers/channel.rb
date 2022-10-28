# frozen_string_literal: true

require_relative "trigger"

module OpenHAB
  module DSL
    module Rules
      module Triggers
        #
        # Creates a channel trigger
        #
        # The channel trigger executes rule when a specific channel is triggered. The syntax
        # supports one or more channels with one or more triggers. `thing` is an optional
        # parameter that makes it easier to set triggers on multiple channels on the same thing.
        #
        #
        # @param [String, Channel, ChannelUID] channels
        #   channels to create triggers for in form of 'binding_id:type_id:thing_id#channel_id'
        #   or 'channel_id' if thing is provided.
        # @param [String, Thing, ThingUID] thing
        #   Thing(s) to create trigger for if not specified with the channel.
        # @param [String, Array<String>] triggered
        #   Only execute rule if the event on the channel matches this/these event/events.
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #   rule "Execute rule when channel is triggered" do
        #     channel "astro:sun:home:rise#event"
        #     run { logger.info("Channel triggered") }
        #   end
        #   # The above is the same as each of the below
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel "rise#event", thing: "astro:sun:home"
        #     run { logger.info("Channel triggered") }
        #   end
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel "rise#event", thing: things["astro:sun:home"]
        #     run { logger.info("Channel triggered") }
        #   end
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel "rise#event", thing: things["astro:sun:home"].uid
        #     run { logger.info("Channel triggered") }
        #   end
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel "rise#event", thing: ["astro:sun:home"]
        #     run { logger.info("Channel triggered") }
        #   end
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel things["astro:sun:home"].channels["rise#event"]
        #     run { logger.info("Channel triggered") }
        #   end
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel things["astro:sun:home"].channels["rise#event"].uid
        #     run { logger.info("Channel triggered") }
        #   end
        #
        # @example
        #   rule "Rule provides access to channel trigger events in run block" do
        #     channel "astro:sun:home:rise#event", triggered: 'START'
        #     run { |trigger| logger.info("Channel(#{trigger.channel}) triggered event: #{trigger.event}") }
        #   end
        #
        # @example
        #   rule "Rules support multiple channels" do
        #     channel "rise#event", "set#event", thing: "astro:sun:home"
        #     run { logger.info("Channel triggered") }
        #   end
        #
        # @example
        #   rule "Rules support multiple channels and triggers" do
        #     channel "rise#event", "set#event", thing: "astro:sun:home", triggered: ["START", "STOP"]
        #     run { logger.info("Channel triggered") }
        #   end
        #
        # @example
        #   rule "Rules support multiple things" do
        #     channel "keypad#code", thing: ["mqtt:homie300:keypad1", "mqtt:homie300:keypad2"]
        #     run { logger.info("Channel triggered") }
        #   end
        #
        def channel(*channels, thing: nil, triggered: nil, attach: nil)
          channel_trigger = Channel.new(rule_triggers: @rule_triggers)
          flattened_channels = Channel.channels(channels: channels, thing: thing)
          triggers = [triggered].flatten
          @ruby_triggers << [:channel, flattened_channels, { triggers: triggers }]
          flattened_channels.each do |channel|
            triggers.each do |trigger|
              channel_trigger.trigger(channel: channel, trigger: trigger, attach: attach)
            end
          end
        end

        # @!visibility private
        #
        # Creates channel triggers
        #
        class Channel < Trigger
          # @return [String] A channel event trigger
          CHANNEL_EVENT = "core.ChannelEventTrigger"

          #
          # Get an enumerator over the product of the channels and things and map them to a channel id
          # @param [Object] channels to iterate over
          # @param [Object] thing to combine with channels and iterate over
          # @return [Enumerable] enumerable channel ids to trigger on
          def self.channels(channels:, thing:)
            logger.trace "Creating Channel/Thing Pairs for channels #{channels.inspect} and things #{thing.inspect}"
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
            thing = thing.uid if thing.is_a?(Core::Things::Thing)
            [thing, channel].compact.join(":")
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
            config = { "channelUID" => channel }
            config["event"] = trigger.to_s unless trigger.nil?
            logger.trace "Creating Channel Trigger for channels #{channel.inspect} and config #{config.inspect}"
            append_trigger(type: CHANNEL_EVENT, config: config, attach: attach)
          end
        end
      end
    end
  end
end
