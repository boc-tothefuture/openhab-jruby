# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      RefreshType = org.openhab.core.types.RefreshType

      # Implements the {REFRESH} command.
      class RefreshType # rubocop:disable Lint/EmptyClass
        # @!parse include Command

        # @!constant REFRESH
        #   Refresh Command

        # @!method refresh?
        #   Check if `self == REFRESH`
        #   @return [true,false]
      end
    end
  end
end

# @!parse
#   RefreshType = OpenHAB::Core::Types::RefreshType
#   REFRESH = OpenHAB::Core::Types::RefreshType::REFRESH
