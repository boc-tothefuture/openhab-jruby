# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      RefreshType = org.openhab.core.types.RefreshType

      # Implements the {REFRESH} command.
      class RefreshType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method refresh?
        #   Check if `self == REFRESH`
        #   @return [true,false]
      end
    end
  end
end
