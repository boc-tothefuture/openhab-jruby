# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      RefreshType = org.openhab.core.types.RefreshType

      # Adds methods to core OpenHAB RefreshType to make it more natural in Ruby
      class RefreshType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method refresh?
        #   Check if `self == REFRESH`
        #   @return [true,false]
      end
    end
  end
end
