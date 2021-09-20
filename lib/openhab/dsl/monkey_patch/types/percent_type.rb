# frozen_string_literal: true

require 'java'
module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB types
      #
      module Types
        java_import Java::OrgOpenhabCoreLibraryTypes::PercentType

        #
        # MonkeyPatching PercentType
        #
        class PercentType
          #
          # Need to override and point to super because default JRuby implementation doesn't point to == of parent class
          #
          # @param [Object] other object to check equality for
          # @return [Boolean] True if other equals self, false otherwise
          #
          # rubocop:disable Lint/UselessMethodDefinition
          def ==(other)
            super
          end
          # rubocop:enable Lint/UselessMethodDefinition

          #
          # Provide details about PercentType object
          #
          # @return [String] Representing details about the PercentType object
          #
          def inspect
            "#{to_string}%"
          end

          #
          # Check if the state is ON
          #
          # @return [Boolean] true if ON, false otherwise
          #
          def on?
            as(OnOffType).on?
          end

          #
          # Check if the state is OFF
          #
          # @return [Boolean] true if OFF, false otherwise
          #
          def off?
            as(OnOffType).off?
          end

          #
          # Check if the state is UP
          #
          # @return [Boolean] true if UP, false otherwise
          #
          def up?
            !!as(UpDownType)&.up?
          end

          #
          # Check if the state is DOWN
          #
          # @return [Boolean] true if DOWN, false otherwise
          #
          def down?
            !!as(UpDownType)&.down?
          end
        end
      end
    end
  end
end
