# frozen_string_literal: true

require 'bigdecimal'
require 'forwardable'
require 'java'
require 'openhab/core/dsl/types/quantity'

module OpenHAB
  module Core
    module DSL
      module Items
        #
        # Delegation to OpenHAB Number Item
        #
        # rubocop: disable Metrics/ClassLength
        # Disabled because this class has a single responsibility, there does not appear a logical
        # way of breaking it up into multiple classes
        class NumberItem < Numeric
          extend Forwardable

          def_delegator :@number_item, :to_s

          java_import org.openhab.core.library.types.DecimalType
          java_import org.openhab.core.library.types.QuantityType
          java_import 'tec.uom.se.format.SimpleUnitFormat'
          java_import 'tec.uom.se.AbstractUnit'

          #
          # Create a new NumberItem
          #
          # @param [Java::Org::openhab::core::library::items::NumberItem] number_item OpenHAB number item to delegate to
          #
          def initialize(number_item)
            @number_item = number_item
            super()
          end

          #
          # Check if NumberItem is truthy? as per defined by library
          #
          # @return [Boolean] True if item is not in state UNDEF or NULL and value is not zero.
          #
          def truthy?
            @number_item.state? && @number_item.state != DecimalType::ZERO
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
              logger.trace("#{self} cannot be coereced to #{other.class}")
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
            logger.trace("Comparing #{self} to #{other}")
            case other
            when NumberItem then number_item_compare(other)
            when Numeric then  @number_item.state.to_big_decimal.to_d <=> other.to_d
            when String  then  @number_item.state <=> QuantityType.new(other) if dimension
            end
          end

          #
          # Convert NumberItem to a Quantity
          #
          # @param [Object] other String or Unit representing an OpenHAB Unit
          #
          # @return [OpenHAB::Core::DSL::Types::Quantity] NumberItem converted to supplied Unit
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
          # @return [OpenHAB::Core::DSL::Types::Quantity] NumberItem converted to a QuantityUnit
          #
          def to_qt
            if dimension
              Quantity.new(@number_item.get_state_as(QuantityType))
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
            @number_item.state.to_big_decimal.to_d if @number_item.state.respond_to? :to_big_decimal
          end

          #
          # Get the Dimension attached to the NumberItem
          #
          # @return [Java::org::openhab::core::library::types::QuantityType] dimension
          #
          def dimension
            @number_item.dimension
          end

          #
          # Forward missing methods to Openhab Number Item if they are defined
          #
          # @param [String] meth method name
          # @param [Array] args arguments for method
          # @param [Proc] block <description>
          #
          # @return [Object] Value from delegated method in OpenHAB NumberItem
          #
          def method_missing(meth, *args, &block)
            logger.trace("Method missing, performing dynamic lookup for: #{meth}")
            if @number_item.respond_to?(meth)
              @number_item.__send__(meth, *args, &block)
            elsif ::Kernel.method_defined?(meth) || ::Kernel.private_method_defined?(meth)
              ::Kernel.instance_method(meth).bind_call(self, *args, &block)
            else
              super(meth, *args, &block)
            end
          end

          #
          # Checks if this method responds to the missing method
          #
          # @param [String] method_name Name of the method to check
          # @param [Boolean] _include_private boolean if private methods should be checked
          #
          # @return [Boolean] true if this object will respond to the supplied method, false otherwise
          #
          def respond_to_missing?(method_name, _include_private = false)
            @number_item.respond_to?(method_name) ||
              ::Kernel.method_defined?(method_name) ||
              ::Kernel.private_method_defined?(method_name)
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
              @number_item.state <=> other.state
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
            elsif @number_item.state?
              [other.to_d, @number_item.state.to_big_decimal.to_d]
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
end
# rubocop: enable Metrics/ClassLength
