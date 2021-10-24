# frozen_string_literal: true

require 'forwardable'

require_relative 'comparable_item'
require_relative 'item_equality'

module OpenHAB
  module DSL
    module Items
      # Mixin for implementing type coercieon, equality, and arithmetic for
      # number-like items
      module NumericItem
        include Comparable
        include ComparableItem

        # apply meta-programming methods to including class
        # @!visibility private
        def self.included(klass)
          klass.prepend ItemEquality # make sure this is first
          klass.extend Forwardable
          klass.delegate %i[+ - * / % | to_d to_f to_i to_int] => :state
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

        %i[positive? negative? zero?].each do |predicate|
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{predicate}              # def positive?
              return false unless state?  #   return false unless state?
                                          #
              state.#{predicate}          #   state.positive?
            end                           # end
          RUBY
        end
      end
    end
  end
end
