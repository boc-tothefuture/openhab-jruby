# frozen_string_literal: true

require 'java'
require 'openhab/dsl/items/item_command'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB items
      #
      module Items
        java_import Java::OrgOpenhabCoreLibraryItems::ContactItem

        #
        # Alias class for ContactItem
        #
        ::Contact = ContactItem

        #
        # Monkey patch Contact Item with Ruby methods
        #
        class ContactItem
          extend OpenHAB::DSL::Items::ItemCommand

          java_import Java::OrgOpenhabCoreLibraryTypes::OpenClosedType

          item_type Java::OrgOpenhabCoreLibraryItems::ContactItem

          #
          # Compares contacts to OpenClosedTypes
          #
          # @param [Object] other object to compare to
          #
          # @return [Boolean] True if contact has a state and state equals other, nil if no state,
          #   result from super if not supplied an OpenClosedType
          #
          def ==(other)
            if other.is_a? OpenClosedType
              state? && state == other
            else
              super
            end
          end
        end
      end
    end
  end
end
