# frozen_string_literal: true

require_relative "numeric_item"
require_relative "switch_item"

module OpenHAB
  module Core
    module Items
      java_import org.openhab.core.library.items.DimmerItem

      # Adds methods to core OpenHAB DimmerItem type to make it more natural in
      # Ruby
      class DimmerItem < SwitchItem
        include NumericItem

        #
        # Dim the dimmer
        #
        # @param [Integer] amount to dim by
        #
        # @return [Integer] level target for dimmer
        #
        def dim(amount = 1)
          target = [state&.-(amount), 0].compact.max
          command(target)
          target
        end

        #
        # Brighten the dimmer
        #
        # @param [Integer] amount to brighten by
        #
        # @return [Integer] level target for dimmer
        #
        def brighten(amount = 1)
          target = [state&.+(amount), 100].compact.min
          command(target)
          target
        end

        # @!method increase
        #   Send the `INCREASE` command to the item
        #   @return [DimmerItem] `self`

        # @!method decrease
        #   Send the `DECREASE` command to the item
        #   @return [DimmerItem] `self`

        # raw numbers translate directly to PercentType, not a DecimalType
        # @!visibility private
        def format_type(command)
          return Types::PercentType.new(command) if command.is_a?(Numeric)

          super
        end
      end
    end
  end
end
