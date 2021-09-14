# frozen_string_literal: true

require 'java'
require 'forwardable'

module OpenHAB
  module DSL
    #
    # Ruby implementation of OpenHAB Types
    #
    module Types
      #
      # Ruby implementation for OpenHAB quantities
      #
      # rubocop: disable Metrics/ClassLength
      # Disabled because this class has a single responsibility, there does not appear a logical
      # way of breaking it up into multiple classes
      class Quantity < Numeric
        extend Forwardable
        include OpenHAB::Log

        def_delegator :@quantity, :to_s
        def_delegators '@quantity.double_value', :positive?, :negative?, :zero?

        java_import org.openhab.core.library.types.QuantityType
        java_import org.openhab.core.library.types.DecimalType
        java_import org.openhab.core.types.util.UnitUtils
        java_import org.openhab.core.library.unit.Units

        # @return [Hash] Mapping of operation symbols to BigDecimal methods
        OPERATIONS = {
          '+' => 'add',
          '-' => 'subtract',
          '*' => 'multiply',
          '/' => 'divide'
        }.freeze

        private_constant :OPERATIONS

        attr_reader :quantity

        #
        # Create a new Quantity
        #
        # @param [object] quantity String,QuantityType or Numeric to be this quantity
        #
        # Cop disabled, case statement is compact and idiomatic
        def initialize(quantity)
          @quantity = case quantity
                      when String then QuantityType.new(quantity)
                      when QuantityType then quantity
                      when NumberItem, Numeric then QuantityType.new(quantity.to_d.to_java, Units::ONE)
                      else raise ArgumentError, "Unexpected type #{quantity.class} provided to Quantity initializer"
                      end
          super()
        end

        #
        # Convert this quantity into a another unit
        #
        # @param [Object] other String or Unit to convert to
        #
        # @return [Quantity] This quantity converted to another unit
        #
        def |(other)
          other = UnitUtils.parse_unit(other) if other.is_a? String

          Quantity.new(quantity.to_unit(other))
        end

        #
        # Compare this quantity
        #
        # @param [Object] other object to compare to
        #
        # @return [Integer] -1,0,1 if this object is less than, equal to, or greater than the supplied object,
        #   nil if it cannot be compared
        #
        def <=>(other)
          logger.trace("Comparing #{self} to #{other}")
          my_qt, other_qt = unitize(*to_qt(coerce(other).reverse))
          my_qt.compare_to(other_qt)
        end

        #
        # Coerce other object into a Quantity
        #
        # @param [Object] other object to convert to Quantity
        #
        # @return [Array] of self and other object as Quantity types, nil if object cannot be coerced
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          case other
          when Quantity then [other.quantity, quantity]
          when QuantityType then [other, quantity]
          when DecimalType then [Quantity.new(other.to_big_decimal.to_d), quantity]
          when NumberItem then [other.to_qt.quantity, quantity]
          when Numeric, String then [Quantity.new(other), self]
          end
        end

        #
        # Forward missing methods to Openhab Quantity Item if they are defined
        #
        # @param [String] meth name of method invoked
        # @param [Array] args arguments to invoked method
        # @param [Proc] block block passed ot method
        #
        # @return [Object] result of delegation
        #
        def method_missing(meth, *args, &block)
          logger.trace("Method missing, performing dynamic lookup for: #{meth}")
          if quantity.respond_to?(meth)
            quantity.__send__(meth, *args, &block)
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
          quantity.respond_to?(method_name) ||
            ::Kernel.method_defined?(method_name) ||
            ::Kernel.private_method_defined?(method_name)
        end

        #
        # Negate the quantity
        #
        # @return [Quantity] This quantity negated
        #
        def -@
          Quantity.new(quantity.negate)
        end

        OPERATIONS.each do |operation, method|
          define_method(operation) do |other|
            logger.trace do
              "Executing math operation '#{operation}' on quantity #{inspect} "\
                "with other type #{other.class} and value #{other.inspect}"
            end

            a, b = to_qt(coerce(other).reverse)
            logger.trace("Coerced a='#{a}' with b='#{b}'")
            a, b = unitize(a, b, operation)
            logger.trace("Unitized a='#{a}' b='#{b}'")
            logger.trace("Performing operation '#{operation}' with method '#{method}' on a='#{a}' with b='#{b}'")
            Quantity.new(a.public_send(method, b))
          end
        end

        #
        # Provide details about quantity object
        #
        # @return [String] Representing details about the quantity object
        #
        def inspect
          if @quantity.unit == Units::ONE
            "unit=#{@quantity.unit}, value=#{@quantity.to_string}"
          else
            @quantity.to_string
          end
        end

        private

        # @return [Array] Array of strings for operations for which the operands will not be unitized
        DIMENSIONLESS_NON_UNITIZED_OPERATIONS = %w[* /].freeze

        # Dimensionless numbers should only be unitzed for addition and subtraction

        #
        # Convert one or more Quantity obects to the underlying quantitytypes
        #
        # @param [Array] quanities Array of either Quantity or QuantityType objects
        #
        # @return [Array]  Array of QuantityType objects
        #
        def to_qt(*quantities)
          [quantities].flatten.compact.map { |item| item.is_a?(Quantity) ? item.quantity : item }
        end

        #
        # Checks if an item should be unitized
        #
        # @param [Quantity] quantity to check
        # @param [String] operation quantity is being used with
        #
        # @return [Boolean] True if the quantity should be unitzed based on the unit and operation, false otherwise
        #
        def unitize?(quantity, operation)
          !(quantity.unit == Units::ONE && DIMENSIONLESS_NON_UNITIZED_OPERATIONS.include?(operation))
        end

        #
        # Convert the unit for the quantity
        #
        # @param [Quantity] quantity being converted
        #
        # @return [Quantity] Quantity coverted to unit set by unit block
        #
        def convert_unit(quantity)
          return quantity unless unit?

          case quantity.unit
          when unit
            quantity
          when Units::ONE
            convert_unit_from_dimensionless(quantity, unit)
          else
            convert_unit_from_dimensioned(quantity, unit)
          end
        end

        #
        # Converts a dimensioned quantity to a specific unit
        #
        # @param [Quantity] quantity to convert
        # @param [Unit] unit to convert to
        #
        # @return [Java::org::openhab::core::library::types::QuantityType] converted quantity
        #
        def convert_unit_from_dimensioned(quantity, unit)
          logger.trace("Converting dimensioned item #{inspect} to #{unit}")
          quantity.to_unit(unit).tap do |converted|
            raise "Conversion from #{quantity.unit} to #{unit} failed" unless converted
          end
        end

        #
        # Converts a dimensionless quantity to a unit
        #
        # @param [Quantity] quantity to convert
        # @param [Unit] unit to convert to
        #
        # @return [Java::org::openhab::core::library::types::QuantityType] converted quantity
        #
        def convert_unit_from_dimensionless(quantity, unit)
          logger.trace("Converting dimensionless #{quantity} to #{unit}")
          QuantityType.new(quantity.to_big_decimal, unit)
        end

        #
        # Convert quantities to appropriate units
        #
        # @param [Quantity] quantity_a Quantity on left side of operation
        # @param [Quantity] quantity_b Quantity on right side of operation
        # @param [String] operation Math operation
        # @yield [quantity_a, quantity_b] yields unitized versions of supplied quantities
        #
        # @return [Array, Object] of quantites in correct units for the supplied operation and the unit
        #   or the result of the block if a block is given
        #
        def unitize(quantity_a, quantity_b, operation = nil)
          logger.trace("Unitizing (#{quantity_a}) and (#{quantity_b})")
          quantity_a, quantity_b = [quantity_a, quantity_b].map do |qt|
            unitize?(qt, operation) ? convert_unit(qt) : qt.to_big_decimal
          end

          # Make sure the operation is called on the QuantityType
          if quantity_a.is_a?(Java::JavaMath::BigDecimal) && quantity_b.is_a?(QuantityType) && operation == '*'
            quantity_a, quantity_b = [quantity_b, quantity_a]
          end
          return yield quantity_a, quantity_b if block_given?

          [quantity_a, quantity_b]
        end

        #
        # Get the unit from the current thread local variable
        #
        # @return [Object] Unit or string representation of Unit, or nil if not set
        #
        def unit
          Thread.current.thread_variable_get(:unit)
        end

        #
        # Is a unit set for this thread
        #
        # @return [boolean] true if a unit is set by this thread, false otherwise
        #
        def unit?
          unit != nil
        end
      end
    end
  end
end
# rubocop: enable Metrics/ClassLength
