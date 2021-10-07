# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      java_import org.openhab.core.library.types.IncreaseDecreaseType

      # Adds methods to core OpenHAB IncreaseDecreaseType to make it more
      # natural in Ruby
      class IncreaseDecreaseType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method increase?
        #   Check if == +INCREASE+
        #   @return [Boolean]

        # @!method decrease?
        #   Check if == +DECREASE+
        #   @return [Boolean]
      end
    end
  end
end
