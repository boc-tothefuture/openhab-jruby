# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Events
        java_import Java::OrgOpenhabCoreItemsEvents::ItemStateEvent

        #
        # MonkeyPatch with ruby style accessors
        #
        class ItemStateEvent
          alias state item_state
        end
      end
    end
  end
end
