# frozen_string_literal: true

module OpenHAB
  module Core
    module Events
      java_import org.openhab.core.thing.link.dto.ItemChannelLinkDTO

      # Strictly speaking this class isn't an event, but it's accessed from an AbstractItemChannelLinkEvent

      # Adds methods to core OpenHAB ItemChannelLinkDTO to make it more natural in Ruby
      class ItemChannelLinkDTO
        # @!method item_name
        #   Gets the name of the item that was linked or unlinked.
        #   @return [String]
        alias_method :item_name, :itemName

        # Gets the item that was linked or unlinked
        # @return [GenericItem]
        def item
          EntityLookup.lookup_item(itemName)
        end

        # Get the channel UID that was linked or unlinked.
        # @return [ChannelUID]
        def channel_uid
          ChannelUID.new(channelUID)
        end
      end
    end
  end
end
