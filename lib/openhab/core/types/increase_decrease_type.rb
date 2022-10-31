# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      IncreaseDecreaseType = org.openhab.core.library.types.IncreaseDecreaseType

      # Represents {INCREASE} and {DECREASE} commands.
      class IncreaseDecreaseType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method increase?
        #   Check if `self == INCREASE`
        #   @return [true,false]

        # @!method decrease?
        #   Check if `self == DECREASE`
        #   @return [true,false]
      end
    end
  end
end
