# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB types
      #
      module Types
        java_import Java::OrgOpenhabCoreLibraryTypes::OnOffType

        #
        # Monkey patching OnOffType
        #
        class OnOffType
          #
          # Invert the type
          #
          # @return [Java::OrgOpenhabCoreLibraryTypes::OnOffType] OFF if ON, ON if OFF
          #
          def !
            return OFF if self == ON
            return ON if self == OFF
          end

          # Check if the supplied object is case equals to self
          #
          # @param [Object] other object to compare
          #
          # @return [Boolean] True if the other object responds to on?/off? and is in the same state as this object,
          #  nil if object cannot be compared
          #
          def ===(other)
            (on? && other.respond_to?(:on?) && other.on?) ||
              (off? && other.respond_to?(:off?) && other.off?) ||
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
              self == other.get_state_as(OnOffType)
            else
              super
            end
          end

          #
          # Check if the state is ON
          #
          # @return [Boolean] true if ON, false otherwise
          #
          def on?
            self == ON
          end

          #
          # Check if the state is OFF
          #
          # @return [Boolean] true if OFF, false otherwise
          #
          def off?
            self == OFF
          end

          alias inspect to_s
        end
      end
    end
  end
end
