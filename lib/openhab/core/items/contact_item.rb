# frozen_string_literal: true

require_relative "generic_item"

module OpenHAB
  module Core
    module Items
      java_import org.openhab.core.library.items.ContactItem

      # Adds methods to core OpenHAB ContactItem type to make it more natural
      # in Ruby
      class ContactItem < GenericItem
        # @!method open?
        #   Check if the item state == `OPEN`
        #   @return [true,false]

        # @!method closed?
        #   Check if the item state == `CLOSED`
        #   @return [true,false]
      end
    end
  end
end
