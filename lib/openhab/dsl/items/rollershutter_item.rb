# frozen_string_literal: true

require_relative "numeric_item"

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.RollershutterItem

      # Adds methods to core OpenHAB RollershutterItem type to make it more natural in
      # Ruby
      class RollershutterItem < GenericItem
        include NumericItem

        alias_method :position, :state

        # @!method up?
        #   Check if the item state == +UP+
        #   @return [Boolean]

        # @!method down?
        #   Check if the item state == +DOWN+
        #   @return [Boolean]

        # @!method up
        #   Send the +UP+ command to the item
        #   @return [RollershutterItem] +self+

        # @!method down
        #   Send the +DOWN+ command to the item
        #   @return [RollershutterItem] +self+

        # @!method stop
        #   Send the +STOP+ command to the item
        #   @return [RollershutterItem] +self+

        # @!method move
        #   Send the +MOVE+ command to the item
        #   @return [RollershutterItem] +self+

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
