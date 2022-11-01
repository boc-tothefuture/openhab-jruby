# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      RawType = org.openhab.core.library.types.RawType

      #
      # This type can be used for all binary data such as images, documents, sounds etc.
      #
      class RawType # rubocop:disable Lint/EmptyClass
        # @!parse include Type

        # @!method mime_type
        #   @return [String]

        # @!method bytes
        #   @return [String]
      end
    end
  end
end
