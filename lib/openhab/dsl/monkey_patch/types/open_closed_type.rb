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
            (open? && other.respond_to?(:open?) && other.open?) ||
              (closed? && other.respond_to?(:closed?) && other.closed?) ||
              super
          end

          #
          # Test for equality
          #
          # @param [Object] other Other object to compare against
          #
          # @return [Boolean] true if self and other can be considered equal, false otherwise
          #
          def ==(other)
            if other.respond_to?(:get_state_as)
              self == other.get_state_as(OpenClosedType)
            else
              super
            end
          end

          #
          # Check if the state is OPEN
          #
          # @return [Boolean] true if OPEN, false otherwise
          #
          def open?
            self == OPEN
          end

          #
          # Check if the state is CLOSED
          #
          # @return [Boolean] true if CLOSED, false otherwise
          #
          def closed?
            self == CLOSED
          end

          alias inspect to_s
        end
      end
    end
  end
end
