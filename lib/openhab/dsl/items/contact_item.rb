# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.ContactItem

      # Adds methods to core OpenHAB ContactItem type to make it more natural
      # in Ruby
      class ContactItem < GenericItem
        # @!method open?
        #   Check if the item state == +OPEN+
        #   @return [Boolean]

        # @!method closed?
        #   Check if the item state == +CLOSED+
        #   @return [Boolean]
      end
    end
  end
end
