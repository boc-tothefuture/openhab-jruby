# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      java_import org.openhab.core.library.types.StopMoveType

      # Adds methods to core OpenHAB StopMoveType to make it more
      # natural in Ruby
      class StopMoveType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method stop?
        #   Check if == +STOP+
        #   @return [Boolean]

        # @!method move?
        #   Check if == +MOVE+
        #   @return [Boolean]
      end
    end
  end
end
