# frozen_string_literal: true

module OpenHAB
  module DSL
    module MonkeyPatch
      module Events
        java_import org.openhab.core.thing.dto.AbstractThingDTO

        # Strictly speaking this class isn't an event, but it's accessed from an AbstractThingRegistryEvent

        # Adds methods to core OpenHAB AbstractThingDTO to make it more natural in Ruby
        class AbstractThingDTO
          # @!method uid
          #   The thing's UID
          #   @return [String]
          alias uid UID

          # @!method thing_type_uid
          #   The thing type's UID
          #   @return [String]
          alias thing_type_uid thingTypeUID

          # @!method bridge_uid
          #   The bridge's UID
          #   @return [String]
          alias bridge_uid bridgeUID
        end
      end
    end
  end
end
