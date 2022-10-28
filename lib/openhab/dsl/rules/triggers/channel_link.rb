# frozen_string_literal: true

require "openhab/dsl/things"
require_relative "trigger"

module OpenHAB
  module DSL
    module Rules
      module Triggers
        include Log

        #
        # Creates a channel linked trigger
        #
        # @param [Object] attach object to be attached to the trigger
        #
        # @example
        #    rule "channel linked" do
        #      channel_linked
        #      run do |event|
        #        logger.info("#{event.link.item.name} linked to #{event.link.channel_uid}.")
        #      end
        #    end
        def channel_linked(attach: nil)
          @ruby_triggers << [:channel_linked]
          trigger("core.GenericEventTrigger", eventTopic: "openhab/links/*/added",
                                              eventTypes: "ItemChannelLinkAddedEvent", attach: attach)
        end

        #
        # Creates a channel unlinked trigger
        #
        # Note that the item or the thing it's linked to may no longer exist,
        # so if you try to access those objects they'll be nil.
        #
        # @param [Object] attach object to be attached to the trigger
        #
        # @example
        #    rule "channel unlinked" do
        #      channel_unlinked
        #      run do |event|
        #        logger.info("#{event.link.item_name} unlinked from #{event.link.channel_uid}.")
        #      end
        #    end
        def channel_unlinked(attach: nil)
          @ruby_triggers << [:channel_linked]
          trigger("core.GenericEventTrigger", eventTopic: "openhab/links/*/removed",
                                              eventTypes: "ItemChannelLinkRemovedEvent", attach: attach)
        end
      end
    end
  end
end
