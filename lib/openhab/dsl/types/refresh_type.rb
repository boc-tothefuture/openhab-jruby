# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      RefreshType = org.openhab.core.types.RefreshType

      # Adds methods to core OpenHAB RefreshType to make it more natural in Ruby
      class RefreshType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method refresh?
        #   Check if == +REFRESH+
        #   @return [Boolean]
      end
    end
  end
end
