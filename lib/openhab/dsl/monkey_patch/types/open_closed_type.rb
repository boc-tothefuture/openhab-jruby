# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB types
      #
      module Types
        java_import Java::OrgOpenhabCoreLibraryTypes::OpenClosedType

        #
        # Monkey patch for DSL use
        #
        class OpenClosedType
          java_import Java::OrgOpenhabCoreLibraryItems::ContactItem

          #
          # Check if the supplied object is case equals to self
          #
          # @param [Object] other object to compare
          #
          # @return [Boolean] True if the other object is a ContactItem and has the same state
          #
          def ===(other)
            super unless other.is_a? ContactItem

            self == other.state
          end
        end
      end
    end
  end
end
