# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      PlayPauseType = org.openhab.core.library.types.PlayPauseType

      # Adds methods to core OpenHAB PlayPauseType to make it more
      # natural in Ruby
      class PlayPauseType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method playing?
        #   Check if == +PLAY+
        #   @return [Boolean]

        # @!parse alias play? playing?

        # @!method paused?
        #   Check if == +PAUSE+
        #   @return [Boolean]

        # @!parse alias pause? paused?
      end
    end
  end
end
