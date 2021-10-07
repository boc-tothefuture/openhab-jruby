# frozen_string_literal: true

require 'forwardable'

require 'openhab/dsl/items/comparable_item'

module OpenHAB
  module DSL
    module Items
      # Mixin for implementing type coercieon, equality, and arithmetic for
      # number-like items
      module NumericItem
        include Comparable
        include ComparableItem

        # apply meta-programming methods to including class
        def self.included(klass)
          klass.extend Forwardable
          klass.delegate %i[+ - * / % | positive? negative? to_d to_f to_i to_int zero?] => :state
          # remove the JRuby default == so that we can inherit the Ruby method
          klass.remove_method :==
        end

        #
        # Check if NumericItem is truthy? as per defined by library
        #
        # @return [Boolean] True if item is not in state +UNDEF+ or +NULL+ and value is not zero.
        #
        def truthy?
          state && !state.zero?
        end

        #
        # Type Coercion
        #
        # Coerce object to a NumericType
        #
        # @param [Types::NumericType, Numeric] other object to coerce to a
        #   DateTimeType
        #
        # @return [[Types::NumericType, Types::NumericType]]
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          return [other, nil] unless state?
          return [other, state] if other.is_a?(Types::NumericType) || other.respond_to?(:to_d)

          raise TypeError, "can't convert #{other.class} into #{self.class}"
        end

        # strip trailing zeros from commands
        # @!visibility private
        def format_type(command)
          # DecimalType and PercentType we want to make sure we don't have extra zeros
          if command.instance_of?(Types::DecimalType) || command.instance_of?(Types::PercentType)
            return command.to_big_decimal.strip_trailing_zeros.to_plain_string
          end
          # BigDecimal types have trailing zeros stripped
          return command.to_java.strip_trailing_zeros.to_plain_string if command.is_a?(BigDecimal)

          super
        end
      end
    end
  end
end
