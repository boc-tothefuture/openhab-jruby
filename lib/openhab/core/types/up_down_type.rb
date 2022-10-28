# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      UpDownType = org.openhab.core.library.types.UpDownType

      # Adds methods to core OpenHAB UpDownType to make it more natural in Ruby
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
