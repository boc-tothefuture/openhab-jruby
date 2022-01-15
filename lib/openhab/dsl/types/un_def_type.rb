# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      UnDefType = org.openhab.core.types.UnDefType

      # Adds methods to core OpenHAB UnDefType to make it more natural in Ruby
      class UnDefType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method null?
        #   Check if == +NULL+
        #   @return [Boolean]

        # @!method undef?
        #   Check if == +UNDEF+
        #   @return [Boolean]
      end
    end
  end
end
