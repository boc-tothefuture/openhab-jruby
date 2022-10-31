# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      UpDownType = org.openhab.core.library.types.UpDownType

      #
      # Implements the {UP} and {DOWN} commands.
      #
      # Also, {PercentType} can be converted to {UpDownType}
      # for more semantic comparisons. `0` is {UP}, `100` is
      # {DOWN}, and anything in-between is neither.
      #
      class UpDownType
        # @!parse include Type

        # @!method up?
        #   Check if `self == UP`
        #   @return [true,false]

        # @!method down?
        #   Check if `self == DOWN`
        #   @return [true,false]

        #
        # Invert the type
        #
        # @return [UpDownType] `UP` if `DOWN`, `DOWN` if `UP`
        #
        def !
          return UP if down?
          return DOWN if up?
        end
      end
    end
  end
end
