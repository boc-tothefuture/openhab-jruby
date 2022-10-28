# frozen_string_literal: true

module OpenHAB
  module Core
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
          EntityLookup.lookup_item(item_name)
        end
      end
    end
  end
end
