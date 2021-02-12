# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Events
        java_import Java::OrgOpenhabCoreItemsEvents::ItemCommandEvent

        #
        # Monkey patch with ruby style accesors
        #
        class ItemCommandEvent
          alias command item_command
        end
      end
    end
  end
end
