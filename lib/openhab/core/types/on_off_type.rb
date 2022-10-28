# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      OnOffType = org.openhab.core.library.types.OnOffType

      # Adds methods to core OpenHAB OnOffType to make it more natural in Ruby
      class OnOffType
        # @!parse include Type

        # @!method on?
        #   Check if `self == ON`
        #   @return [true,false]

        # @!method off?
        #   Check if `self == OFF`
        #   @return [true,false]

        # Invert the type
        # @return [OnOffType] `OFF` if `ON`, `ON` if `OFF`
        def !
          on? ? OFF : ON
        end
      end
    end
  end
end
