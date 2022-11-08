# frozen_string_literal: true

module OpenHAB
  module Core
    module Things
      java_import org.openhab.core.thing.link.ItemChannelLink

      #
      # Represents the link between an {Items::GenericItem} and Thing's
      # Channel.
      #
      class ItemChannelLink
        # @!attribute [r] item
        # @return [Items::GenericItem]
        def item
          DSL.items[item_name]
        end
      end
    end
  end
end
