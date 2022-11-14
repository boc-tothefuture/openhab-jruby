# frozen_string_literal: true

require_relative "numeric_type"
require_relative "type"

module OpenHAB
  module Core
    module Types
      QuantityType = org.openhab.core.library.types.QuantityType

      # {QuantityType} extends {DecimalType} to handle physical unit measurement.
      class QuantityType
        # @!parse include Command, State
        include NumericType
        include ComparableType

        # private alias
        ONE_UNIT = org.openhab.core.library.unit.Units::ONE
        private_constant :ONE_UNIT

        #
        # Convert this quantity into a another unit
        #
        alias_method :|, :to_unit

        #
        # Comparison
        #
        # Comparisons against Numeric and DecimalType are allowed only within a {DSL.unit}
        # block to avoid unit ambiguities.
        # Comparisons against other types may be done if supported by that type's coercion.
        #
        # @param [QuantityType, DecimalType, Numeric, Object]
        #   other object to compare to
        #
        # @return [Integer, nil] -1, 0, +1 depending on whether `other` is
        #   less than, equal to, or greater than self
        #
        #   `nil` is returned if the two values are incomparable.
        #
        def <=>(other)
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          case other
          when self.class
            return unitize(other.unit).compare_to(other) if unit == ONE_UNIT
            return compare_to(other.unitize(unit)) if other.unit == ONE_UNIT

            return compare_to(other)
          when Numeric, DecimalType
            return compare_to(QuantityType.new(other, OpenHAB::DSL.unit)) if OpenHAB::DSL.unit

            return nil # don't allow comparison with numeric outside a unit block
          end

          return nil unless other.respond_to?(:coerce)

          other.coerce(self)&.then { |lhs, rhs| lhs <=> rhs }
        end

        #
        # Type Coercion
        #
        # Coerce object to a QuantityType
        #
        # @param [Numeric, Type] other object to coerce to a {QuantityType}
        #
        #   if `other` is a {Type}, `self` will instead be coerced
        #   to that type to accomodate comparison with things such as {OnOffType}
        #
        # @return [[QuantityType, QuantityType], nil]
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          if other.is_a?(Type)
            [other, as(other.class)]
          elsif other.respond_to?(:to_d)
            [QuantityType.new(other.to_d.to_java, ONE_UNIT), self]
          end
        end

        # arithmetic operators
        alias_method :-@, :negate

        {
          add: :+,
          subtract: :-
        }.each do |java_op, ruby_op|
          convert = "self.class.new(other, DSL.unit || unit)"

          class_eval( # rubocop:disable Style/DocumentDynamicEvalDefinition https://github.com/rubocop/rubocop/issues/10179
            # def +(other)
            #   logger.trace("#{self} + #{other} (#{other.class})")
            #   if other.is_a?(QuantityType)
            #     add_quantity(other)
            #   elsif other.is_a?(DecimalType)
            #     other = other.to_big_decimal
            #     add_quantity(self.class.new(other, Units.unit || unit))
            #   elsif other.is_a?(java.math.BigDecimal)
            #     add_quantity(self.class.new(other, Units.unit || unit))
            #   elsif other.respond_to?(:to_d)
            #     other = other.to_d.to_java
            #     add_quantity(self.class.new(other, Units.unit || unit))
            #   elsif other.respond_to?(:coerce) && (lhs, rhs = other.coerce(to_d))
            #     lhs + rhs
            #   else
            #     raise TypeError, "#{other.class} can't be coerced into #{self.class}"
            #   end
            # end
            <<~RUBY, __FILE__, __LINE__ + 1
              def #{ruby_op}(other)
                logger.trace("\#{self} #{ruby_op} \#{other} (\#{other.class})")
                if other.is_a?(QuantityType)
                  #{java_op}_quantity(other)
                elsif other.is_a?(DecimalType)
                  other = other.to_big_decimal
                  #{java_op}_quantity(#{convert})
                elsif other.is_a?(java.math.BigDecimal)
                  #{java_op}_quantity(#{convert})
                elsif other.respond_to?(:to_d)
                  other = other.to_d.to_java
                  #{java_op}_quantity(#{convert})
                elsif other.respond_to?(:coerce) && (lhs, rhs = other.coerce(to_d))
                  lhs #{ruby_op} rhs
                else
                  raise TypeError, "\#{other.class} can't be coerced into \#{self.class}"
                end
              end
            RUBY
          )
        end

        {
          multiply: :*,
          divide: :/
        }.each do |java_op, ruby_op|
          class_eval( # rubocop:disable Style/DocumentDynamicEvalDefinition https://github.com/rubocop/rubocop/issues/10179
            # def *(other)
            #   logger.trace("#{self} * #{other} (#{other.class})")
            #   if other.is_a?(QuantityType)
            #     multiply_quantity(other)
            #   elsif other.is_a?(DecimalType)
            #     multiply(other.to_big_decimal)
            #   elsif other.is_a?(java.math.BigDecimal)
            #     multiply(other)
            #   elsif other.respond_to?(:to_d)
            #     multiply(other.to_d.to_java)
            #   elsif other.respond_to?(:coerce) && (lhs, rhs = other.coerce(to_d))
            #     lhs * rhs
            #   else
            #     raise TypeError, "#{other.class} can't be coerced into #{self.class}"
            #   end
            # end
            <<~RUBY, __FILE__, __LINE__ + 1
              def #{ruby_op}(other)
                logger.trace("\#{self} #{ruby_op} \#{other} (\#{other.class})")
                if other.is_a?(QuantityType)
                  #{java_op}_quantity(other)
                elsif other.is_a?(DecimalType)
                  #{java_op}(other.to_big_decimal)
                elsif other.is_a?(java.math.BigDecimal)
                  #{java_op}(other)
                elsif other.respond_to?(:to_d)
                  #{java_op}(other.to_d.to_java)
                elsif other.respond_to?(:coerce) && (lhs, rhs = other.coerce(to_d))
                  lhs #{ruby_op} rhs
                else
                  raise TypeError, "\#{other.class} can't be coerced into \#{self.class}"
                end
              end
            RUBY
          )
        end

        # if it's a dimensionless quantity, change the unit to match other_unit
        # @!visibility private
        def unitize(other_unit = unit)
          # prefer converting to the thread-specified unit if there is one
          other_unit = DSL.unit || other_unit
          logger.trace("Converting #{self} to #{other_unit}")

          case unit
          when ONE_UNIT
            QuantityType.new(to_big_decimal, other_unit)
          when other_unit
            self
          else
            to_unit(other_unit)
          end
        end

        # if unit is `ONE_UNIT`, return a plain Java BigDecimal
        # @!visibility private
        def deunitize
          return to_big_decimal if unit == ONE_UNIT

          self
        end

        private

        # do addition directly against a QuantityType while ensuring we unitize
        # both sides
        def add_quantity(other)
          unitize(other.unit).add(other.unitize(unit))
        end

        # do subtraction directly against a QuantityType while ensuring we
        # unitize both sides
        def subtract_quantity(other)
          unitize(other.unit).subtract(other.unitize(unit))
        end

        # do multiplication directly against a QuantityType while ensuring
        # we deunitize both sides, and also invert the operation if one side
        # isn't actually a unit
        def multiply_quantity(other)
          lhs = deunitize
          rhs = other.deunitize
          # reverse the arguments if it's multiplication and the LHS isn't a QuantityType
          lhs, rhs = rhs, lhs if lhs.is_a?(java.math.BigDecimal)
          # what a waste... using a QuantityType to multiply two dimensionless quantities
          # have to make sure lhs is still a QuantityType in order to return a new
          # QuantityType that's still dimensionless
          lhs = other if lhs.is_a?(java.math.BigDecimal)

          lhs.multiply(rhs)
        end

        alias_method :divide_quantity, :divide
      end
    end
  end
end

# @!parse QuantityType = OpenHAB::Core::Types::QuantityType
