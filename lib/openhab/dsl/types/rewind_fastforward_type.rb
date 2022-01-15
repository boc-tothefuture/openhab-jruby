# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      RewindFastforwardType = org.openhab.core.library.types.RewindFastforwardType

      # Adds methods to core OpenHAB RewindFastforwardType to make it more
      # natural in Ruby
      class RewindFastforwardType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method rewinding?
        #   Check if == +REWIND+
        #   @return [Boolean]

        # @!parse alias rewind? rewinding?

        # @!method fast_forwarding?
        #   Check if == +FASTFORWARD+
        #   @return [Boolean]

        # @!parse alias fast_forward? fast_forwarding?

        # @deprecated
        # @!parse alias fastforward? fast_forwarding?

        # @deprecated
        # @!parse alias fastforwarding? fast_forwarding?
      end
    end
  end
end
