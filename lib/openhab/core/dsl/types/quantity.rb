# frozen_string_literal: true

require 'java'
require 'forwardable'

module OpenHAB
  module Core
    module DSL
      module Types
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

          def inspect
            if @quantity.unit == AbstractUnit::ONE
              "unit=#{@quantity.unit}, value=#{@quantity.to_string}"
            else
              @quantity.to_string
            end
          end

          attr_reader :quantity

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

          # Convert the number to the specified unit
          def |(other)
            other = SimpleUnitFormat.instance.unitFor(other) if other.is_a? String

            Quantity.new(quantity.to_unit(other))
          end

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

          # Forward missing methods to Openhab Number Item if they are defined
          def method_missing(meth, *args, &block)
            if quantity.respond_to?(meth)
              quantity.__send__(meth, *args, &block)
            elsif ::Kernel.method_defined?(meth) || ::Kernel.private_method_defined?(meth)
              ::Kernel.instance_method(meth).bind_call(self, *args, &block)
            else
              super(meth, *args, &block)
            end
          end

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

          private

          DIMENSIONLESS_NON_UNITIZED_OPERATIONS = %w[* /].freeze

          # Dimensionless numbers should only be unitzed for addition and subtraction
          def unitize?(item, operation)
            if item.unit == AbstractUnit::ONE && DIMENSIONLESS_NON_UNITIZED_OPERATIONS.include?(operation)
              false
            else
              true
            end
          end

          def convert_unit(item)
            if unit
              case item.unit
              when AbstractUnit::ONE
                logger.trace("Converting dimensionless #{item} to #{unit}")
                QuantityType.new(item.to_big_decimal, unit)
              when unit
                item
              else
                logger.trace("Converting dimensioned item #{inspect} to #{unit}")
                converted = item.to_unit(unit)
                raise "Conversion from #{item.unit} to #{unit} failed" if converted.nil?

                converted
              end
            else
              item
            end
          end

          def unitize(a, b, operation)
            [a, b].map { |qt| unitize?(qt, operation) ? convert_unit(qt) : qt }
          end

          def unit
            Thread.current.thread_variable_get(:unit)
          end
        end
      end
    end
  end
end
