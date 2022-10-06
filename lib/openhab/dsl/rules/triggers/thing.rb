# frozen_string_literal: true

require 'openhab/log/logger'
require 'openhab/dsl/things'
require_relative 'trigger'

module OpenHAB
  module DSL
    module Rules
      module Triggers
        include OpenHAB::Log

        #
        # Creates a thing added trigger
        #
        # @param [Object] attach object to be attached to the trigger
        #
        # @example
        #    rule "thing added" do
        #      thing_added
        #      run do |event|
        #        logger.info("#{event.thing.uid} added.")
        #      end
        #    end
        def thing_added(attach: nil)
          @ruby_triggers << [:thing_added]
          trigger('core.GenericEventTrigger', eventTopic: 'openhab/things/*/added',
                                              eventTypes: 'ThingAddedEvent', attach: attach)
        end

        #
        # Creates a thing removed trigger
        #
        # @param [Object] attach object to be attached to the trigger
        #
        # @example
        #    rule "thing removed" do
        #      thing_removed
        #      run do |event|
        #        logger.info("#{event.thing.uid} removed.")
        #      end
        #    end
        def thing_removed(attach: nil)
          @ruby_triggers << [:thing_removed]
          trigger('core.GenericEventTrigger', eventTopic: 'openhab/things/*/removed',
                                              eventTypes: 'ThingRemovedEvent', attach: attach)
        end

        #
        # Creates a thing updated trigger
        #
        # @param [Object] attach object to be attached to the trigger
        #
        # @example
        #    rule "thing updated" do
        #      thing_updated
        #      run do |event|
        #        logger.info("#{event.thing.uid} updated.")
        #      end
        #    end
        def thing_updated(attach: nil)
          @ruby_triggers << [:thing_removed]
          trigger('core.GenericEventTrigger', eventTopic: 'openhab/things/*/updated',
                                              eventTypes: 'ThingUpdatedEvent', attach: attach)
        end
      end
    end
  end
end
