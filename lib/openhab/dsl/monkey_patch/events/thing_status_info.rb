# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Event
        java_import org.openhab.core.thing.events.ThingStatusInfoChangedEvent
        java_import org.openhab.core.thing.events.ThingStatusInfoEvent
        #
        # Monkey patch with ruby style accessors
        #
        class ThingStatusInfoChangedEvent
          alias uid get_thing_uid
          alias last get_old_status_info
          alias status status_info

          # Get the thing that triggered this event
          def thing
            things[uid]
          end
        end

        #
        # Monkey patch with ruby style accessors
        #
        class ThingStatusInfoEvent
          alias uid get_thing_uid
          alias status status_info

          # Get the thing that triggered this event
          def thing
            things[uid]
          end
        end
      end
    end
  end
end
