# frozen_string_literal: true

module OpenHAB
  module Core
    module Events
      java_import org.openhab.core.thing.dto.AbstractThingDTO

      # Strictly speaking this class isn't an event, but it's accessed from an AbstractThingRegistryEvent

      # Adds methods to core openHAB AbstractThingDTO to make it more natural in Ruby
      class AbstractThingDTO
        # @!method uid
        #   The thing's UID
        #   @return [String]
        alias_method :uid, :UID

        # @!method thing_type_uid
        #   The thing type's UID
        #   @return [String]
        alias_method :thing_type_uid, :thingTypeUID

        # @!method bridge_uid
        #   The bridge's UID
        #   @return [String]
        alias_method :bridge_uid, :bridgeUID
      end
    end
  end
end
