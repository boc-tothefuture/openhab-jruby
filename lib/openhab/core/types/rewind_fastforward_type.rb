# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      RewindFastforwardType = org.openhab.core.library.types.RewindFastforwardType

      # Adds methods to core OpenHAB RewindFastforwardType to make it more
      # natural in Ruby
      class RewindFastforwardType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

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
