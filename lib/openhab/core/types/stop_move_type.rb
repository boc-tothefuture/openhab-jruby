# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      StopMoveType = org.openhab.core.library.types.StopMoveType

      # Implements the {STOP} and {MOVE} commands.
      class StopMoveType # rubocop:disable Lint/EmptyClass
        # @!parse include Command

        # @!constant STOP
        #   Stop Command
        # @!constant MOVE
        #   Move Command

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

# @!parse
#   StopMoveType = OpenHAB::Core::Types::StopMoveType
#   STOP = OpenHAB::Core::Types::StopMoveType::STOP
#   MOVE = OpenHAB::Core::Types::StopMoveType::MOVE
