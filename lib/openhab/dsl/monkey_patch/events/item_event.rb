# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Events
        java_import Java::OrgOpenhabCoreItemsEvents::ItemEvent

        #
        # MonkeyPatch to add item
        #
        class ItemEvent
          #
          # Return a decorated item
          #
          def item
            OpenHAB::Core::EntityLookup.lookup_item(item_name)
          end
        end
      end
    end
  end
end
