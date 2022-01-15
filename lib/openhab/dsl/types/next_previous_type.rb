# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      NextPreviousType = org.openhab.core.library.types.NextPreviousType

      # Adds methods to core OpenHAB NextPreviousType to make it more
      # natural in Ruby
      class NextPreviousType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method next?
        #   Check if == +NEXT+
        #   @return [Boolean]

        # @!method previous?
        #   Check if == +PREVIOUS+
        #   @return [Boolean]
      end
    end
  end
end
