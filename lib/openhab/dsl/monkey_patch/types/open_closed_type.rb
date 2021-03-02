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
            if other.respond_to?(:state)
              self == other.state
            elsif other.is_a? OpenClosedType
              self == other
            else
              super
            end
          end
        end
      end
    end
  end
end
