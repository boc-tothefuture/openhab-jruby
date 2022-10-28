# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      PlayPauseType = org.openhab.core.library.types.PlayPauseType

      # Adds methods to core OpenHAB PlayPauseType to make it more
      # natural in Ruby
      class PlayPauseType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method playing?
        #   Check if `self == PLAY`
        #   @return [true,false]

        # @!parse alias play? playing?

        # @!method paused?
        #   Check if `self == PAUSE`
        #   @return [true,false]

        # @!parse alias pause? paused?
      end
    end
  end
end
