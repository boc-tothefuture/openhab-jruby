# frozen_string_literal: true

require 'java'
require 'forwardable'

module OpenHAB
  module Core
    module DSL
      #
      # Ruby implementation of OpenHAB Types
      #
      module Types
        #
        # Ruby implementation for OpenHAB quantities
        #
        class Quantity < Numeric
          extend Forwardable
          include Logging

          def_delegator :@quantity, :to_s

          java_import org.openhab.core.library.types.QuantityType
          java_import 'tec.uom.se.format.SimpleUnitFormat'
          java_import 'tec.uom.se.AbstractUnit'

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
          # @param [Java::org::openhab::core::library::types::QuantityType] quantity OpenHAB quantity to delegate to
          #
          def initialize(quantity)
            @quantity = case quantity
                        when String
                          QuantityType.new(quantity)
                        when QuantityType
                          quantity
                        when Numeric
                          QuantityType.new(BigDecimal(quantity).to_java, AbstractUnit::ONE)
                        else
                          raise "Unexpected type #{quantity.class} provided to Quantity initializer"
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
            other = SimpleUnitFormat.instance.unitFor(other) if other.is_a? String

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
            case other
            when Quantity
              logger.trace("Comparing Quantity #{self} to Quantity #{other}")
              convert_unit(quantity).compare_to(convert_unit(other.quantity))
            when QuantityType
              other = convert_unit(other)
              quantity.compare_to(other)
            when String
              other = QuantityType.new(other)
              other = convert_unit(other)
              quantity.compare_to(other)
            when Numeric
              quantity.compare_to(QuantityType.new(other, unit)) if unit
            end
          end

          #
          # Coerce other object into a Quantity
          #
          # @param [Object] other object to convert to Quantity
          #
          # @return [Array] of self and other object as Quantity types, nil if object cannot be coerced
          #
          def coerce(other)
            logger.trace("Coercing #{self} as a request from  #{other.class}")
            case other
            when Quantity
              [other.quantity, quantity]
            when QuantityType
              [other, quantity]
            when Numeric
              [Quantity.new(other), self]
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
            if quantity.respond_to?(meth)
              quantity.__send__(meth, *args, &block)
            elsif ::Kernel.method_defined?(meth) || ::Kernel.private_method_defined?(meth)
              ::Kernel.instance_method(meth).bind_call(self, *args, &block)
            else
              super(meth, *args, &block)
            end
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
              logger.trace("Executing math operation '#{operation}' on quantity #{inspect} with other type #{other.class} and value #{other.inspect}")
              a, b = case other
                     when Quantity
                       [quantity, other.quantity]
                     when String
                       [quantity, QuantityType.new(other)]
                     when NumberItem
                       a, b = other.coerce(self)
                       logger.trace("Number Item coerced result a(#{a.class})='#{a}' b(#{b.class})='#{b}'")
                       [a.quantity, b.quantity]
                     when Numeric
                       [quantity, QuantityType.new(BigDecimal(other).to_java, AbstractUnit::ONE)]
                     else
                       raise TypeError,
                             "Operation '#{operation}' cannot be performed between #{self} and #{other.class}"
                     end
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
            if @quantity.unit == AbstractUnit::ONE
              "unit=#{@quantity.unit}, value=#{@quantity.to_string}"
            else
              @quantity.to_string
            end
          end

          private

          DIMENSIONLESS_NON_UNITIZED_OPERATIONS = %w[* /].freeze

          # Dimensionless numbers should only be unitzed for addition and subtraction


          #
          # Checks if an item should be unitized
          #
          # @param [Quantity] quantity to check
          # @param [String] operation quantity is being used with
          #
          # @return [Boolean] True if the quantity should be unitzed based on the unit and operation, false otherwise
          #
          def unitize?(quantity, operation)
            if quantity.unit == AbstractUnit::ONE && DIMENSIONLESS_NON_UNITIZED_OPERATIONS.include?(operation)
              false
            else
              true
            end
          end

          #
          # Convert the unit for the quantity
          #
          # @param [Quantity] quantity being converted
          #
          # @return [Quantity] Quantity coverted to unit set by unit block
          #
          def convert_unit(quantity)
            if unit
              case quantity.unit
              when AbstractUnit::ONE
                logger.trace("Converting dimensionless #{quantity} to #{unit}")
                QuantityType.new(quantity.to_big_decimal, unit)
              when unit
                quantity
              else
                logger.trace("Converting dimensioned item #{inspect} to #{unit}")
                converted = quantity.to_unit(unit)
                raise "Conversion from #{quantity.unit} to #{unit} failed" if converted.nil?

                converted
              end
            else
              quantity
            end
          end

          #
          # Convert quantities to appropriate units 
          #
          # @param [Quantity] quantity_a Quantity on left side of operation
          # @param [Quantity] quantity_b Quantity on right side of operation
          # @param [String] operation Math operation
          #
          # @return [Array] of quantites in correct units for the supplied operation and set unit
          #
          def unitize(quantity_a, quantity_b, operation)
            [quantity_a, quantity_b].map { |qt| unitize?(qt, operation) ? convert_unit(qt) : qt }
          end

          #
          # Get the unit from the current thread local variable
          #
          # @return [Object] Unit or string representation of Unit, or nil if not set
          #
          def unit
            Thread.current.thread_variable_get(:unit)
          end
        end
      end
    end
  end
end
