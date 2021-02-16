# frozen_string_literal: true

require 'forwardable'
require 'java'
require 'openhab/dsl/items/item_command'
require 'openhab/dsl/items/item_delegate'

module OpenHAB
  module DSL
    module Items
      #
      # Delegator to OpenHAB Rollershutter Item
      #
      class RollershutterItem < Numeric
        extend Forwardable
        extend OpenHAB::DSL::Items::ItemCommand
        extend OpenHAB::DSL::Items::ItemDelegate
        include Comparable

        def_item_delegator :@rollershutter_item

        item_type Java::OrgOpenhabCoreLibraryItems::RollershutterItem

        #
        # Creates a new RollershutterItem
        #
        # @param [Java::OrgOpenhabCoreLibraryItems::RollershutterItem] rollershutter_item
        #   The OpenHAB RollershutterItem to delegate to
        #
        def initialize(rollershutter_item)
          logger.trace("Wrapping #{rollershutter_item}")
          @rollershutter_item = rollershutter_item

          item_missing_delegate { @rollershutter_item }
          item_missing_delegate { position }

          super()
        end

        #
        # Returns the rollershutter's position
        #
        # @return [Java::OrgOpenhabCoreLibraryTypes::PercentType] the position of the rollershutter
        #
        def position
          state&.as(PercentType)
        end

        #
        # Compare the rollershutter's position against another object
        #
        # @param [Object] other object to compare against
        #
        # @return [Integer] -1, 0 or 1 depending on the result of the comparison
        #
        def <=>(other)
          return nil unless state?

          case other
          when PercentType, Java::OrgOpenhabCoreLibraryTypes::DecimalType then position.compare_to(other)
          when Numeric then position.int_value <=> other
          when RollershutterItem then position.compare_to(other.position)
          when UpDownType then state.as(UpDownType) == other
          end
        end

        #
        # Coerce self into other to enable calculations
        #
        # @param [Numeric] other Other numeric to coerce into
        #
        # @return [Array<Numeric>] an array of other and self coerced into other's type
        #
        def coerce(other)
          raise ArgumentError, "Cannot coerce to #{other.class}" unless other.is_a? Numeric

          case other
          when Integer then [other, position&.int_value]
          when Float then [other, position&.float_value]
          end
        end

        #
        # Define math operations
        #
        %i[+ - * / %].each do |operator|
          define_method(operator) do |other|
            right, left = coerce(other)
            left&.send(operator, right)
          end
        end
      end
    end
  end
end
