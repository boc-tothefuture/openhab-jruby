# frozen_string_literal: true

require "forwardable"

require_relative "comparable_item"
require_relative "item_equality"

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
          klass.delegate %i[+ - * / % to_d to_f to_i to_int] => :state
          # remove the JRuby default == so that we can inherit the Ruby method
          klass.remove_method :==
        end

        #
        # Convert state to a Quantity by calling state (DecimalType)#|
        # Raise a NoMethodError if state is nil (NULL or UNDEF) instead of delegating to it.
        # because nil#| would return true, causing an unexpected result
        #
        # @param [Unit, String] other the unit to convert to
        #
        # @return [QuantityType] the QuantityType in the given unit
        #
        def |(other)
          raise NoMethodError, "State is nil" unless state?

          state.|(other)
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
        end

        # raw numbers translate directly to DecimalType, not a string
        # @!visibility private
        def format_type(command)
          return Types::DecimalType.new(command) if command.is_a?(Numeric)

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
