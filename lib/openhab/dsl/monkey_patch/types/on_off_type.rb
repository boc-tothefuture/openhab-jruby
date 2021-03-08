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
            # A case statement here causes and infinite loop
            # rubocop:disable Style/CaseLikeIf
            if self == ON
              other.on? if other.respond_to? :on?
            elsif self == OFF
              other.off? if other.respond_to?('off?')
            else
              false
            end
            # rubocop:enable Style/CaseLikeIf
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
        end
      end
    end
  end
end
