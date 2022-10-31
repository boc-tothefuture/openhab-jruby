# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      OpenClosedType = org.openhab.core.library.types.OpenClosedType

      # Implements {OPEN} and {CLOSED} states.
      class OpenClosedType
        # @!parse include Type

        # @!method open?
        #   Check if `self == OPEN`
        #   @return [true,false]

        # @!method closed?
        #   Check if `self == CLOSED`
        #   @return [true,false]

        # Invert the type
        # @return [OpenClosedType] `OPEN` if `CLOSED`, `CLOSED` if `OPEN`
        def !
          return CLOSED if open?
          return OPEN if closed?
        end
      end
    end
  end
end
