# frozen_string_literal: true

require 'bigdecimal'
require 'forwardable'
require 'java'
require 'openhab/dsl/types/quantity'
require 'openhab/dsl/items/item_delegate'

module OpenHAB
  module DSL
    module Items
      #
      # Delegation to OpenHAB Number Item
      #
      # rubocop: disable Metrics/ClassLength
      # Disabled because this class has a single responsibility, there does not appear a logical
      # way of breaking it up into multiple classes
      class NumberItem < Numeric
        extend OpenHAB::DSL::Items::ItemDelegate
        extend OpenHAB::DSL::Items::ItemCommand

        def_item_delegator :@oh_item
        attr_reader :oh_item

        java_import org.openhab.core.library.types.DecimalType
        java_import org.openhab.core.library.types.QuantityType
        java_import 'tec.uom.se.format.SimpleUnitFormat'
        java_import 'tec.uom.se.AbstractUnit'

        item_type Java::OrgOpenhabCoreLibraryItems::NumberItem

        #
        # Create a new NumberItem
        #
        # @param [Java::Org::openhab::core::library::items::NumberItem] number_item OpenHAB number item to delegate to
        #
        def initialize(number_item)
          @oh_item = number_item
          item_missing_delegate { @oh_item }
          super()
        end

        #
        # Check if NumberItem is truthy? as per defined by library
        #
        # @return [Boolean] True if item is not in state UNDEF or NULL and value is not zero.
        #
        def truthy?
          @oh_item.state? && @oh_item.state != DecimalType::ZERO
        end

        #
        # Coerce objects into a NumberItem
        #
        # @param [Object] other object to coerce to a NumberItem if possible
        #
        # @return [Object] NumberItem, QuantityTypes, BigDecimal or nil depending on NumberItem configuration
        #  and/or supplied object
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from  #{other.class}")
          case other
          when Quantity then coerce_from_quantity(other)
          when Numeric then  coerce_from_numeric(other)
          else
            logger.trace("#{self} cannot be coerced to #{other.class}")
            nil
          end
        end

        #
        # Compare NumberItem to supplied object
        #
        # @param [Object] other object to compare to
        #
        # @return [Integer] -1,0,1 or nil depending on value supplied,
        #   nil comparison to supplied object is not possible.
        #
        def <=>(other)
          logger.trace("NumberItem #{self} <=> #{other} (#{other.class})")
          case other
          when NumberItem then number_item_compare(other)
          when Numeric then numeric_compare(other)
          when String then string_compare(other)
          else state_compare(other)
          end
        end

        #
        # Convert NumberItem to a Quantity
        #
        # @param [Object] other String or Unit representing an OpenHAB Unit
        #
        # @return [OpenHAB::DSL::Types::Quantity] NumberItem converted to supplied Unit
        #
        def |(other)
          other = SimpleUnitFormat.instance.unitFor(other) if other.is_a? String

          if dimension
            to_qt | other
          else
            Quantity.new(QuantityType.new(to_d.to_java, other))
          end
        end

        #
        # Convert NumberItem to a Quantity
        #
        # @return [OpenHAB::DSL::Types::Quantity] NumberItem converted to a QuantityUnit
        #
        def to_qt
          if dimension
            Quantity.new(@oh_item.get_state_as(QuantityType))
          else
            Quantity.new(QuantityType.new(to_d.to_java, AbstractUnit::ONE))
          end
        end

        #
        # Converts the NumberItem to an Integer
        #
        # @return [Integer] NumberItem as an integer
        #
        def to_i
          to_d&.to_i
        end

        #
        # Converts the NumberItem to a float
        #
        # @return [Float] NumberItem as a float
        #
        def to_f
          to_d&.to_f
        end

        #
        # Converts the NumberItem to a BigDecimal
        #
        # @return [BigDecimal] NumberItem as a BigDecimal
        #
        def to_d
          @oh_item.state.to_big_decimal.to_d if @oh_item.state.respond_to? :to_big_decimal
        end

        #
        # Get the Dimension attached to the NumberItem
        #
        # @return [Java::org::openhab::core::library::types::QuantityType] dimension
        #
        def dimension
          @oh_item.dimension
        end

        %w[+ - * /].each do |operation|
          define_method(operation) do |other|
            logger.trace("Execution math operation '#{operation}' on #{inspect} with #{other.inspect}")
            left_operand, right_operand = operands_for_operation(other)
            left_operand.public_send(operation, right_operand)
          end
        end

        private

        #
        # Compare if other responds to state
        #
        # @param [Object] other object to compare to
        #
        # @return [Integer] -1,0,1 depending on less than, equal to or greater than other
        #
        def state_compare(other)
          other = other.state if other.respond_to? :state
          @oh_item.state <=> other
        end

        #
        # Compare if other is a String
        #
        # @param [String] other object to compare to
        #
        # @return [Integer] -1,0,1,nil depending on less than, equal to or greater than other
        #   nil if this number item does not have a dimension
        #
        def string_compare(other)
          @oh_item.state <=> QuantityType.new(other) if dimension
        end

        #
        # Compare if other is a Numeric
        #
        # @param [String] other to compare to
        #
        # @return [Integer] -1,0,1 depending on less than, equal to or greater than other
        #
        def numeric_compare(other)
          @oh_item.state.to_big_decimal.to_d <=> other.to_d
        end

        #
        # Get the operands for any operation
        #
        # @param [Object] other object to convert to a compatible operand
        #
        # @return [Array[Object,Object]] of operands where the first value is the left operand
        #   and the second value is the right operand
        #
        def operands_for_operation(other)
          case other
          when NumberItem then number_item_operands(other)
          when Numeric then [to_d, other.to_d]
          when String then string_operands(other)
          else
            return other.coerce(to_d) if other.respond_to? :coerce

            raise ArgumentError, "#{other.class} can't be coerced into a NumberItem"
          end
        end

        #
        # Get operands for an operation when the right operand is provided as a string
        #
        # @param [String] other right operand
        #
        # @return [Array[QuantityType,QuantiyType]] of operands where the first value is the left operand
        #   and the second value is the right operand
        #
        def string_operands(other)
          return [to_qt, Quantity.new(other)] if dimension

          raise ArgumentError, 'Strings are only valid operands if NumberItem is dimensions=ed.'
        end

        #
        # Get operands for an operation when the right operand is provided is another number item
        #
        # @param [NumberItem] other right operand
        #
        # @return [Array<QuantityType,QuantityType>,Array<BigDecimal,BigDecimal>] of operands depending on
        #   if the left or right operand has a dimensions
        #
        def number_item_operands(other)
          if dimension || other.dimension
            dimensioned_operands(other)
          else
            logger.trace("Both objects lack dimension, self='#{self}' other='#{other}'")
            # If nothing has a dimension, just use BigDecimals
            [to_d, other.to_d]
          end
        end

        #
        # Get operands for an operation when the left or right operand has a dimension
        #
        # @param [NumberItem] other right operand
        #
        # @return [Array<QuantityType,QuantityType>] of operands
        #
        def dimensioned_operands(other)
          logger.trace("Dimensions self='#{dimension}' other='#{other.dimension}'")
          if dimension
            if other.dimension
              # If both numbers have dimensions, do the math on the quantity types.
              [to_qt, other.to_qt]
            else
              # If this number has dimension and the other does not,
              # do math with this quantity type and the other as a big decimal
              [to_qt, other]
            end
          else
            # If this number has no dimension and the other does, convert this into a dimensionless quantity
            [to_qt, other]
          end
        end

        #
        # Compare two number items, taking into account any dimensions
        #
        # @param [NumberItem] other number item
        #
        # @return [-1,0,1] depending on if other object is less than, equal to or greater than self
        #
        def number_item_compare(other)
          if other.dimension
            logger.trace('Other is dimensioned, converting self and other to QuantityTypes to compare')
            to_qt <=> other.to_qt
          else
            @oh_item.state <=> other.state
          end
        end

        #
        # Coerce from a numberic object depnding on dimension and state
        #
        # @param [Numeric] other numeric object to convert
        #
        # @return [Array<QuantityType,QuantityType>,Array<BigDecimal,BigDecimal>,nil] depending on
        #   if this object has a dimension or state
        #
        def coerce_from_numeric(other)
          if dimension
            [Quantity.new(other), to_qt]
          elsif @oh_item.state?
            [other.to_d, @oh_item.state.to_big_decimal.to_d]
          end
        end

        #
        # Coerce when other is a quantity
        #
        # @param [QuantityType] other
        #
        # @return [Array<QuanityType,QuantityType] other and self as a quantity type
        #
        def coerce_from_quantity(other)
          as_qt = to_qt
          logger.trace("Converted #{self} to a Quantity #{as_qt}")
          [other, as_qt]
        end
      end
    end
  end
end
# rubocop: enable Metrics/ClassLength
