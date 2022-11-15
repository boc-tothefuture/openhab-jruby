# frozen_string_literal: true

module OpenHAB
  module Core
    #
    # Contains the core {Thing} that bindings use to represent connected devices,
    # as well as related infrastructure.
    #
    module Things
      java_import org.openhab.core.thing.ThingStatus,
                  org.openhab.core.thing.ThingUID,
                  org.openhab.core.thing.ThingTypeUID

      class << self
        # @!visibility private
        def manager
          @manager ||= OSGi.service("org.openhab.core.thing.ThingManager")
        end
      end
    end
  end
end
