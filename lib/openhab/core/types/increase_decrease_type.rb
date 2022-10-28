# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      IncreaseDecreaseType = org.openhab.core.library.types.IncreaseDecreaseType

      # Adds methods to core OpenHAB IncreaseDecreaseType to make it more
      # natural in Ruby
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
