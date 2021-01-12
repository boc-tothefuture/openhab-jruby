# frozen_string_literal: true

require 'bigdecimal'
require 'forwardable'
require 'java'
require 'openhab/core/dsl/types/quantity'

module OpenHAB
  module Core
    module DSL
      module Items
        class NumberItem < Numeric
          extend Forwardable

          def_delegator :@number_item, :to_s

          java_import org.openhab.core.library.types.DecimalType
          java_import org.openhab.core.library.types.QuantityType
          java_import 'tec.uom.se.format.SimpleUnitFormat'
          java_import 'tec.uom.se.AbstractUnit'

          def initialize(number_item)
            @number_item = number_item
            super()
          end

          def truthy?
            @number_item.state? && @number_item.state != DecimalType::ZERO
          end

          def coerce(other)
            logger.trace("Coercing #{self} as a request from  #{other.class}")
            case other
            when Quantity
              as_qt = to_qt
              logger.trace("Converted #{self} to a Quantity #{as_qt}")
              [other, as_qt]
            when Numeric
              if dimension
                [Quantity.new(other), to_qt]
              elsif @number_item.state?
                [BigDecimal(other), @number_item.state.to_big_decimal.to_d]
              end
            else
              logger.trace("#{self} cannot be coereced to #{other.class}")
              nil
            end
          end

          def <=>(other)
            logger.trace("Comparing #{self} to #{other}")
            case other
            when NumberItem
              if other.dimension
                logger.trace('Other is dimensioned, converting self and other to QuantityTypes to compare')
                to_qt <=> other.to_qt
              else
                @number_item.state <=> other.state
              end
            when Numeric
              @number_item.state.to_big_decimal.to_d <=> BigDecimal(other)
            when String
              @number_item.state <=> QuantityType.new(other) if dimension
            end
          end

          # Convert the number to the specified unit
          def |(other)
            other = SimpleUnitFormat.instance.unitFor(other) if other.is_a? String

            if dimension
              to_qt | other
            else
              Quantity.new(QuantityType.new(to_d.to_java, other))
            end
          end

          def to_qt
            if dimension
              Quantity.new(@number_item.get_state_as(QuantityType))
            else
              Quantity.new(QuantityType.new(to_d.to_java, AbstractUnit::ONE))
            end
          end

          def to_i
            to_d&.to_i
          end

          def to_f
            to_d&.to_f
          end

          def to_d
            @number_item.state.to_big_decimal.to_d if @number_item.state.respond_to? :to_big_decimal
          end

          def dimension
            @number_item.dimension
          end

          # Forward missing methods to Openhab Number Item if they are defined
          def method_missing(meth, *args, &block)
            if @number_item.respond_to?(meth)
              @number_item.__send__(meth, *args, &block)
            elsif ::Kernel.method_defined?(meth) || ::Kernel.private_method_defined?(meth)
              ::Kernel.instance_method(meth).bind_call(self, *args, &block)
            else
              super(meth, *args, &block)
            end
          end

          %w[+ - * /].each do |operation|
            define_method(operation) do |other|
              logger.trace("Execution math operation '#{operation}' on #{inspect} with #{other.inspect}")
              if other.is_a? NumberItem
                logger.trace('Math operations is between two NumberItems.')
                if dimension && other.dimension
                  # If both numbers have dimensions, do the math on the quantity types.
                  logger.trace("Both objects have dimensions self='#{dimension}' other='#{other.dimension}'")
                  to_qt.public_send(operation, other.to_qt)
                elsif dimension && !other.dimension
                  # If this number has dimension and the other does not, do math with this quantity type and the other as a big decimal
                  logger.trace("Self has dimension self='#{dimension}' other lacks dimension='#{other}'")
                  to_qt.public_send(operation, other)
                elsif other.dimension
                  # If this number has no dimension and the other does, convert this into a dimensionless quantity
                  logger.trace("Self has no dimension self='#{self}' other has dimension='#{other.dimension}'")
                  to_qt.public_send(operation, other)
                else
                  logger.trace("Both objects lack dimension, self='#{self}' other='#{other}'")
                  # If nothing has a dimension, just use BigDecimals
                  to_d.public_send(operation, other.to_d)
                end
              elsif other.is_a? Numeric
                to_d.public_send(operation, BigDecimal(other))
              elsif dimension && other.is_a?(String)
                to_qt.public_send(operation, Quantity.new(other))
              elsif other.respond_to? :coerce
                a, b = other.coerce(to_d)
                a.public_send(operation, b)
              else
                raise TypeError, "#{other.class} can't be coerced into a NumberItem"
              end
            end
          end
        end
      end
    end
  end
end