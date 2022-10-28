# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      StopMoveType = org.openhab.core.library.types.StopMoveType

      # Adds methods to core OpenHAB StopMoveType to make it more
      # natural in Ruby
      class StopMoveType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method stop?
        #   Check if `self == STOP`
        #   @return [true,false]

        # @!method move?
        #   Check if `self == MOVE`
        #   @return [true,false]
      end
    end
  end
end
