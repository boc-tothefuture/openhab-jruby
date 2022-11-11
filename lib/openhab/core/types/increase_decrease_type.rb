# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      IncreaseDecreaseType = org.openhab.core.library.types.IncreaseDecreaseType

      # Represents {INCREASE} and {DECREASE} commands.
      class IncreaseDecreaseType # rubocop:disable Lint/EmptyClass
        # @!parse include Command

        # @!constant INCREASE
        #   Increase Command
        # @!constant DECREASE
        #   Decrease Command

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

# @!parse
#   IncreaseDecreaseType = OpenHAB::Core::Types::IncreaseDecreaseType
#   INCREASE = OpenHAB::Core::Types::IncreaseDecreaseType::INCREASE
#   DECREASE = OpenHAB::Core::Types::IncreaseDecreaseType::DECREASE
