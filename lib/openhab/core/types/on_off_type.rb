# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      OnOffType = org.openhab.core.library.types.OnOffType

      #
      # Implements {ON} and {OFF} commands and states.
      #
      # Also, {PercentType} can be converted to {OnOffType}
      # for more semantic comparisons. `0` is {OFF}, anything
      # else if {ON}.
      #
      class OnOffType
        # @!parse include Command, State

        # @!constant ON
        #   On Command/State
        # @!constant OFF
        #   Off Command/State

        # @!method on?
        #   Check if `self == ON`
        #   @return [true,false]

        # @!method off?
        #   Check if `self == OFF`
        #   @return [true,false]

        # Invert the type
        # @return [OnOffType] {OFF} if {on?}, {ON} if {off?}
        def !
          on? ? OFF : ON
        end
      end
    end
  end
end

# @!parse
#   OnOffType = OpenHAB::Core::Types::OnOffType
#   ON = OpenHAB::Core::Types::OnOffType::ON
#   OFF = OpenHAB::Core::Types::OnOffType::OFF
