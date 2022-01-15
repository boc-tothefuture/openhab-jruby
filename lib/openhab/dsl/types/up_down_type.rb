# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      UpDownType = org.openhab.core.library.types.UpDownType

      # Adds methods to core OpenHAB UpDownType to make it more natural in Ruby
      class UpDownType
        # @!parse include Type

        # @!method up?
        #   Check if == +UP+
        #   @return [Boolean]

        # @!method down?
        #   Check if == +DOWN+
        #   @return [Boolean]

        #
        # Invert the type
        #
        # @return [UpDownType] +UP+ if +DOWN+, +DOWN+ if +UP+
        #
        def !
          return UP if down?
          return DOWN if up?
        end
      end
    end
  end
end
