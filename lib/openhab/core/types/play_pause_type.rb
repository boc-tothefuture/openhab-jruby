# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      PlayPauseType = org.openhab.core.library.types.PlayPauseType

      # Implements {PLAY} and {PAUSE} commands and states.
      class PlayPauseType # rubocop:disable Lint/EmptyClass
        # @!parse include Command, State

        # @!constant PLAY
        #   Play Command/Playing State
        # @!constant PAUSE
        #   Pause Command/Paused State

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

# @!parse
#   PlayPauseType = OpenHAB::Core::Types::PlayPauseType
#   PLAY = OpenHAB::Core::Types::PlayPauseType::PLAY
#   PAUSE = OpenHAB::Core::Types::PlayPauseType::PAUSE
