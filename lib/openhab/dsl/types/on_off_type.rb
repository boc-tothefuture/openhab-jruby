# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      OnOffType = org.openhab.core.library.types.OnOffType

      # Adds methods to core OpenHAB OnOffType to make it more natural in Ruby
      class OnOffType
        # @!parse include Type

        # @!method on?
        #   Check if == +ON+
        #   @return [Boolean]

        # @!method off?
        #   Check if == +OFF+
        #   @return [Boolean]

        # Invert the type
        # @return [OnOffType] +OFF+ if +ON+, +ON+ if +OFF+
        def !
          return OFF if on?
          return ON if off?
        end
      end
    end
  end
end
