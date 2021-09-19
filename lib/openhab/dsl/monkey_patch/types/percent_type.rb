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
        end
      end
    end
  end
end
