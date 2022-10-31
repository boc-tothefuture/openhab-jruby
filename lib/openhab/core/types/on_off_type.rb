# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      OnOffType = org.openhab.core.library.types.OnOffType

      #
      # Implements {ON} and {OFF} commands and states.
      #
      # Also, {PercentType} can be converted to {OnOffType}
      # for more semantic comparisons. `0` is {OFF}, anything
      # else if {ON}.
      #
      class OnOffType
        # @!parse include Type

        # @!method on?
        #   Check if `self == ON`
        #   @return [true,false]

        # @!method off?
        #   Check if `self == OFF`
        #   @return [true,false]

        # Invert the type
        # @return [OnOffType] `OFF` if `ON`, `ON` if `OFF`
        def !
          on? ? OFF : ON
        end
      end
    end
  end
end
