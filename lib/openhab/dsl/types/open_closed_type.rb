# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      java_import org.openhab.core.library.types.OpenClosedType

      # Adds methods to core OpenHAB OpenClosedType to make it more natural in Ruby
      class OpenClosedType
        # @!parse include Type

        # @!method open?
        #   Check if == +OPEN+
        #   @return [Boolean]

        # @!method closed?
        #   Check if == +CLOSED+
        #   @return [Boolean]

        # Invert the type
        # @return [OpenClosedType] +OPEN+ if +CLOSED+, +CLOSED+ if +OPEN+
        def !
          return OPEN if open?
          return CLOSED if closed?
        end
      end
    end
  end
end
