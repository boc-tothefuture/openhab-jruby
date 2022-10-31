# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      NextPreviousType = org.openhab.core.library.types.NextPreviousType

      # Implements {NEXT} and {PREVIOUS} commands.
      class NextPreviousType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method next?
        #   Check if `self == NEXT`
        #   @return [true,false]

        # @!method previous?
        #   Check if `self == PREVIOUS`
        #   @return [true,false]
      end
    end
  end
end
