# frozen_string_literal: true

module OpenHAB
  module Core
    module Things
      # @interface
      java_import org.openhab.core.thing.Thing

      #
      # A {Thing} is a representation of a connected part (e.g. physical device
      # or cloud service) from the real world. It contains a list of
      # {Channel Channels}, which can be bound to {GenericItem Items}.
      #
      # @see OpenHAB::DSL.things things[]
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
      # @!attribute [r] status
      #   Return the {https://www.openhab.org/docs/concepts/things.html#thing-status thing status}
      #   @return [org.openhab.core.thing.ThingStatus]
      #
      # @!attribute [r] channels
      #   @return [ChannelArray]
      #
      module Thing
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

        class << self
          # @!visibility private
          #
          # Override to support Proxy
          #
          def ===(other)
            other.is_a?(self)
          end
        end

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

        ThingStatus.constants.each do |thingstatus|
          define_method("#{thingstatus.to_s.downcase}?") { status == ThingStatus.value_of(thingstatus) }
        end

        #
        # Enable the Thing
        #
        # @param [true, false] enabled
        # @return [void]
        #
        def enable(enabled: true)
          Things.manager.set_enabled(uid, enabled)
        end

        #
        # Disable the Thing
        #
        # @return [void]
        #
        def disable
          enable(enabled: false)
        end

        # @return [String]
        def inspect
          r = "#<OpenHAB::Core::Things::Thing #{uid}"
          r += " #{label.inspect}" if label
          r += " (#{location.inspect})" if location
          r += " #{status}"
          unless status_info.status_detail == org.openhab.core.thing.ThingStatusDetail::NONE
            r += " (#{status_info.status_detail})"
          end
          r += " configuration=#{configuration.properties.to_h}" unless configuration.properties.empty?
          r += " properties=#{properties.to_h}" unless properties.empty?
          "#{r}>"
        end

        # @return [String]
        def to_s
          uid.to_s
        end

        #
        # Fetches the actions available for this thing.
        #
        # Default scope actions are available directly on the thing object, via
        # {#method_missing}.
        #
        # @param [String, nil] scope The action scope. Default's to the thing's binding.
        # @return [Object, nil]
        #
        # @example
        #   things["max:thermostat:mybridge:thermostat"].actions("max-devices").delete_from_cube
        #
        # @example (see #method_missing)
        #
        def actions(scope = nil)
          $actions.get(scope || uid.binding_id, uid.to_s)
        end

        #
        # Delegate missing methods to the thing's default actions scope.
        #
        # @example
        #   things['mail:smtp:local'].send_email('me@example.com', 'subject', 'message')
        #
        def method_missing(method, *args, &block)
          return actions.public_send(method, *args, &block) if actions.respond_to?(method)

          super
        end

        # @!visibility private
        def respond_to_missing?(method_name, _include_private = false)
          logger.trace("Checking if Thing #{uid} supports #{method_name} action")
          return true if actions.respond_to?(method_name)

          super
        end
      end
    end
  end
end
