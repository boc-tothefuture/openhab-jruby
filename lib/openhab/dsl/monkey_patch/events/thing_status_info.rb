# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Event
        java_import Java::OrgOpenhabCoreThingEvents::ThingStatusInfoChangedEvent
        java_import Java::OrgOpenhabCoreThingEvents::ThingStatusInfoEvent
        #
        # Monkey patch with ruby style accessors
        #
        class ThingStatusInfoChangedEvent
          alias uid get_thing_uid
          alias last get_old_status_info
          alias status status_info
        end

        #
        # Monkey patch with ruby style accessors
        #
        class ThingStatusInfoEvent
          alias uid get_thing_uid
          alias status status_info
        end
      end
    end
  end
end
