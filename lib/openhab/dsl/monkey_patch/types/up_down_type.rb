# frozen_string_literal: true

require 'java'
module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB types
      #
      module Types
        java_import Java::OrgOpenhabCoreLibraryTypes::UpDownType

        #
        # MonkeyPatching UpDownType
        #
        class UpDownType
          #
          # Check if the supplied object is case equals to self
          #
          # @param [Object] other object to compare
          #
          # @return [Boolean] True if the other object is a RollershutterItem and has the same state
          #
          def ===(other)
            if other.respond_to?(:state)
              self == other.state&.as(UpDownType)
            elsif other.is_a? UpDownType
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
