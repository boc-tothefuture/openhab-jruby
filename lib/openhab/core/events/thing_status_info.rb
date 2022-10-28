# frozen_string_literal: true

module OpenHAB
  module Core
    module Events
      java_import org.openhab.core.thing.events.ThingStatusInfoChangedEvent
      java_import org.openhab.core.thing.events.ThingStatusInfoEvent

      class ThingStatusInfoChangedEvent
        alias_method :uid, :get_thing_uid
        alias_method :last, :get_old_status_info
        alias_method :status, :status_info

        # Get the thing that triggered this event
        def thing
          EntityLookup.lookup_thing(uid)
        end
      end

      class ThingStatusInfoEvent
        alias_method :uid, :get_thing_uid
        alias_method :status, :status_info

        # Get the thing that triggered this event
        def thing
          EntityLookup.lookup_thing(uid)
        end
      end
    end
  end
end
