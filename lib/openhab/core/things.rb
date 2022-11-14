# frozen_string_literal: true

require "delegate"

require "singleton"

module OpenHAB
  module Core
    #
    # Contains the core {Thing} that bindings use to represent connected devices,
    # as well as related infrastructure.
    #
    module Things
      java_import org.openhab.core.thing.ThingStatus

      class << self
        # @!visibility private
        def manager
          @manager ||= OSGi.service("org.openhab.core.thing.ThingManager")
        end
      end

      #
      # The core class that bindings use to represent connected devices.
      #
      # @see DSL.things things[]
      # @see EntityLookup
      #
      # @example
      #   thing = things["chromecast:audiogroup:dd9f8622-eee-4eaf-b33f-cdcdcdeee001121"]
      #   logger.info("Audiogroup Status: #{thing&.status}")
      #   logger.info("Audiogroup Online? #{thing&.online?}")
      #   logger.info("Channel ids: #{thing.channels.map(&:uid)}")
      #   logger.info("Items linked to volume channel: #{thing.channels['volume']&.items&.map(&:name)&.join(', ')}")
      #   logger.info("Item linked to volume channel: #{thing.channels['volume']&.item&.name}")
      #
      # @example Thing actions can be called directly through a Thing object
      #   things["mqtt:broker:mosquitto"].publishMQTT("zigbee2mqttt/bridge/config/permit_join", "true")
      #   things["mail:smtp:local"].sendMail("me@example.com", "Subject", "Email body")
      #
      # @example Thing can be accessed directly through {EntityLookup entity lookup}
      #   # replace ':' with '_' in thing uid
      #   mqtt_broker_mosquitto.online? # is mqtt:broker:mosquitto thing online?
      #
      class Thing < SimpleDelegator
        # Array wrapper class to allow searching a list of channels
        # by channel id
        class ChannelsArray < Array
          # Allows indexing by both integer as an array or channel id acting like a hash.
          # @param [Integer, String] index Numeric index or string channel id to search for.
          def [](index)
            if index.respond_to?(:to_str)
              key = index.to_str
              return find { |channel| channel.uid.id == key }
            end

            super
          end
        end

        def initialize(thing)
          super
          @actions = actions_for_thing(uid)
        end

        #
        # @!method status
        #   Return the {https://www.openhab.org/docs/concepts/things.html#thing-status thing status}
        #   @return [org.openhab.core.thing.ThingStatus] Thing status
        #

        #
        # @!method uninitialized?
        #   Check if thing status == UNINITIALIZED
        #   @return [true,false]
        #

        #
        # @!method initialized?
        #   Check if thing status == INITIALIZED
        #   @return [true,false]
        #

        #
        # @!method unknown?
        #   Check if thing status == UNKNOWN
        #   @return [true,false]
        #

        #
        # @!method online?
        #   Check if thing status == ONLINE
        #   @return [true,false]
        #

        #
        # @!method offline?
        #   Check if thing status == OFFLINE
        #   @return [true,false]
        #

        #
        # @!method removing?
        #   Check if thing status == REMOVING
        #   @return [true,false]
        #

        #
        # @!method removed?
        #   Check if thing status == REMOVED
        #   @return [true,false]
        #

        # @!visibility private
        #
        # Defines boolean thing status methods
        #   uninitialized?
        #   initializing?
        #   unknown?
        #   online?
        #   offline?
        #   removing?
        #   removed?
        #
        # @return [true,false] true if the thing status matches the name
        #
        ThingStatus.constants.each do |thingstatus|
          define_method("#{thingstatus.to_s.downcase}?") { status == ThingStatus.value_of(thingstatus) }
        end

        # Returns the list of channels associated with this Thing
        # @return [Array] channels
        def channels
          ChannelsArray.new(super.to_a)
        end

        # Enable the Thing
        def enable(enabled: true)
          Things.manager.set_enabled(uid, enabled)
        end

        # Disable the Thing
        def disable
          enable(enabled: false)
        end

        # @return [String]
        def inspect
          "#<OpenHAB::Core::Things::Thing #{uid}>"
        end

        # @return [String]
        def to_s
          uid.to_s
        end

        #
        # Delegate missing methods to thing actions
        #
        def method_missing(method, *args, &block)
          @actions&.each do |action|
            next unless action.respond_to?(method)

            logger.trace("Calling Thing #{uid} action method #{method}")
            return action.public_send(method, *args)
          end
          super
        end

        # @!visibility private
        def respond_to_missing?(method_name, _include_private = false)
          logger.trace("Checking if Thing #{uid} supports #{method_name} action")
          @actions&.each do |action|
            return true if action.respond_to?(method_name)
          end
          super
        end
      end
    end
  end
end
