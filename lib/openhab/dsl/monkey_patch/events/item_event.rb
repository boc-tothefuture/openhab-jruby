# frozen_string_literal: true

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Events
        java_import org.openhab.core.items.events.ItemEvent

        #
        # Adds methods to core OpenHAB ItemEvent to make it more natural in Ruby
        #
        class ItemEvent
          #
          # The triggering item
          #
          # @return [GenericItem]
          #
          def item
            OpenHAB::Core::EntityLookup.lookup_item(item_name)
          end
        end
      end
    end
  end
end
