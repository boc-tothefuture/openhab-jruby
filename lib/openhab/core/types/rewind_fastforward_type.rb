# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      RewindFastforwardType = org.openhab.core.library.types.RewindFastforwardType

      # Implements the {REWIND} and {FASTFORWARD} commands and states.
      class RewindFastforwardType # rubocop:disable Lint/EmptyClass
        # @!parse include Command, State

        # @!constant REWIND
        #   Rewind Command/Rewinding State
        # @!constant FASTFORWARD
        #   Fast Forward Command/Fast Forwarding State

        # @!method rewinding?
        #   Check if `self == REWIND`
        #   @return [true,false]

        # @!parse alias rewind? rewinding?

        # @!method fast_forwarding?
        #   Check if `self == FASTFORWARD`
        #   @return [true,false]

        # @!parse alias fast_forward? fast_forwarding?
      end
    end
  end
end

# @!parse
#   RewindFastforwardType = OpenHAB::Core::Types::RewindFastforwardType
#   REWIND = OpenHAB::Core::Types::RewindFastforwardType::REWIND
#   FASTFORWARD = OpenHAB::Core::Types::RewindFastforwardType::FASTFORWARD
