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
        # @!attribute [r] item
        # @return [Items::GenericItem] The item that triggered this event.
        #
        def item
          EntityLookup.lookup_item(item_name)
        end
      end
    end
  end
end
