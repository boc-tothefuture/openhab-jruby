# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      UnDefType = org.openhab.core.types.UnDefType

      # Adds methods to core OpenHAB UnDefType to make it more natural in Ruby
      class UnDefType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method null?
        #   Check if `self == NULL`
        #   @return [true,false]

        # @!method undef?
        #   Check if `self == UNDEF`
        #   @return [true,false]
      end
    end
  end
end
