# frozen_string_literal: true

require_relative "comparable_type"
require_relative "numeric_type"

module OpenHAB
  module DSL
    module Types
      DecimalType = org.openhab.core.library.types.DecimalType

      #
      # Add methods to core OpenHAB DecimalType to make it behave as a Ruby
      # BigDecimal object
      #
      #
      # Any method not explicitly defined is forwarded to the +BigDecimal+
      # representation of this object.
      #
      class DecimalType
        # @!parse include Type
        include NumericType
        include ComparableType

        #
        # Create a new instance of DecimalType
        #
        # @param [java.math.BigDecimal, Items::NumericItem, Numeric] args Create a DecimalType from the given value
        #
        def initialize(*args)
          unless args.length == 1
            super
            return
          end

          value = args.first
          if value.is_a?(java.math.BigDecimal)
            super
          elsif value.is_a?(BigDecimal)
            super(value.to_java.strip_trailing_zeros)
          elsif value.is_a?(DecimalType)
            super(value.to_big_decimal)
          elsif value.is_a?(Items::NumericItem) ||
                (value.is_a?(Items::GroupItem) && value.base_item.is_a?(Items::NumericItem))
            super(value.state)
          elsif value.respond_to?(:to_d)
            super(value.to_d.to_java.strip_trailing_zeros)
          else # rubocop:disable Lint/DuplicateBranch
            # duplicates the Java BigDecimal branch, but that needs to go first
            # in order to avoid unnecessary conversions
            super
          end
        end

        #
        # Convert DecimalType to a QuantityType
        #
        # @param [Object] other String or Unit representing an OpenHAB Unit
        #
        # @return [QuantityType] +self+ as a {QuantityType} of the supplied Unit
        #
        def |(other)
          other = org.openhab.core.types.util.UnitUtils.parse_unit(other.to_str) if other.respond_to?(:to_str)
          QuantityType.new(to_big_decimal, other)
        end

        #
        # Comparison
        #
        # @param [NumericType, Items::NumericItem, Numeric]
        #   other object to compare to
        #
        # @return [Integer, nil] -1, 0, +1 depending on whether +other+ is
        #   less than, equal to, or greater than self
        #
        #   nil is returned if the two values are incomparable
        #
        def <=>(other)
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          if other.is_a?(QuantityType)
            (other <=> self)&.-@
          elsif other.is_a?(self.class)
            compare_to(other)
          elsif other.is_a?(Items::NumericItem) ||
                (other.is_a?(Items::GroupItem) && other.base_item.is_a?(NumericItem))
            return nil unless other.state?

            self <=> other.state
          elsif other.respond_to?(:to_d)
            to_d <=> other.to_d
          elsif other.respond_to?(:coerce)
            return nil unless (lhs, rhs = other.coerce(self))

            lhs <=> rhs
          end
        end

        #
        # Type Coercion
        #
        # Coerce object to a DecimalType
        #
        # @param [Items::NumericItem, Numeric, Type] other object to
        #   coerce to a {DecimalType}
        #
        #   if +other+ is a {Type}, +self+ will instead be coerced
        #   to that type to accomodate comparison with things such as {OnOffType}
        #
        # @return [[DecimalType, DecimalType]]
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          if other.is_a?(Items::NumericItem) ||
             (other.is_a?(Items::GroupItem) && other.base_item.is_a?(Items::NumericItem))
            return unless other.state?

            [other.state, self]
          elsif other.is_a?(Type)
            [other, as(other.class)]
          elsif other.respond_to?(:to_d)
            [self.class.new(other.to_d), self]
          end
        end

        #
        # Unary minus
        #
        # Negates self
        #
        # @return [DecimalType]
        def -@
          self.class.new(to_big_decimal.negate)
        end

        {
          add: :+,
          subtract: :-,
          multiply: :*,
          divide: :/,
          remainder: :%,
          pow: :**
        }.each do |java_op, ruby_op|
          class_eval( # rubocop:disable Style/DocumentDynamicEvalDefinition https://github.com/rubocop/rubocop/issues/10179
            # def +(other)
            #   if other.is_a?(DecimalType)
            #     self.class.new(to_big_decimal.add(other.to_big_decimal))
            #   elsif other.is_a?(java.math.BigDecimal)
            #     self.class.new(to_big_decimal.add(other))
            #   elsif other.respond_to?(:to_d)
            #     result = to_d + other
            #     # result could already be a QuantityType
            #     result = self.class.new(result) unless result.is_a?(NumericType)
            #     result
            #   elsif other.respond_to?(:coerce) && (lhs, rhs = other.coerce(to_d))
            #     lhs + rhs
            #   else
            #     raise TypeError, "#{other.class} can't be coerced into #{self.class}"
            #   end
            # end
            <<~RUBY, __FILE__, __LINE__ + 1
              def #{ruby_op}(other)
                if other.is_a?(DecimalType)
                  self.class.new(to_big_decimal.#{java_op}(other.to_big_decimal, java.math.MathContext::DECIMAL128))
                elsif other.is_a?(java.math.BigDecimal)
                  self.class.new(to_big_decimal.#{java_op}(other, java.math.MathContext::DECIMAL128))
                elsif other.respond_to?(:to_d)
                  result = to_d #{ruby_op} other
                  # result could already be a QuantityType
                  result = self.class.new(result) unless result.is_a?(NumericType)
                  result
                elsif other.respond_to?(:coerce) && (lhs, rhs = other.coerce(to_d))
                  lhs #{ruby_op} rhs
                else
                  raise TypeError, "\#{other.class} can't be coerced into \#{self.class}"
                end
              end
            RUBY
          )
        end

        # any method that exists on BigDecimal gets forwarded to to_d
        delegate (BigDecimal.instance_methods - instance_methods) => :to_d
      end
    end
  end
end
