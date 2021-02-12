# frozen_string_literal: true

require 'java'

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
          java_import org.openhab.core.library.types.OpenClosedType
          #
          # Check if the contact is open
          #
          # @return [Boolean] True if contact has state and is open, false otherwise
          #
          def open?
            state? && state == OpenClosedType::OPEN
          end

          #
          # Check if the contact is closed
          #
          # @return [Boolean] True if contact has state and is closed, false otherwise
          #
          def closed?
            state? && state == OpenClosedType::CLOSED
          end

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
