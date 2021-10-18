# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB items
    #
    module Items
      java_import org.openhab.core.library.items.ContactItem

      # Alias class for ContactItem
      ::Contact = ContactItem

      # Adds methods to core OpenHAB ContactItem type to make it more natural
      # in Ruby
      class ContactItem < GenericItem
        remove_method :==

        #
        # Return the inverted state of the contact: +CLOSED+ if the contact is
        # +OPEN+, +UNDEF+ or +NULL+; +OPEN+ if the contact is +CLOSED+
        #
        # @return [Types::OpenClosedType] Inverted state
        #
        def !
          return !state if state?

          CLOSED
        end

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
