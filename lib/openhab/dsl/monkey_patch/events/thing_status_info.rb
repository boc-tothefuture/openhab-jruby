# frozen_string_literal: true

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
          alias_method :uid, :get_thing_uid
          alias_method :last, :get_old_status_info
          alias_method :status, :status_info

          # Get the thing that triggered this event
          def thing
            things[uid]
          end
        end

        #
        # Monkey patch with ruby style accessors
        #
        class ThingStatusInfoEvent
          alias_method :uid, :get_thing_uid
          alias_method :status, :status_info

          # Get the thing that triggered this event
          def thing
            things[uid]
          end
        end
      end
    end
  end
end
