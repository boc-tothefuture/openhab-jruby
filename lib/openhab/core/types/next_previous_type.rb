# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      NextPreviousType = org.openhab.core.library.types.NextPreviousType

      # Implements {NEXT} and {PREVIOUS} commands.
      class NextPreviousType # rubocop:disable Lint/EmptyClass
        # @!parse include Command

        # @!constant NEXT
        #   Next Command
        # @!constant PREVIOUS
        #   Previous Command

        # @!method next?
        #   Check if `self == NEXT`
        #   @return [true,false]

        # @!method previous?
        #   Check if `self == PREVIOUS`
        #   @return [true,false]
      end
    end
  end
end

# @!parse
#   NextPreviousType = OpenHAB::Core::Types::NextPreviousType
#   NEXT = OpenHAB::Core::Types::NextPreviousType::NEXT
#   PREVIOUS = OpenHAB::Core::Types::NextPreviousType::PREVIOUS
