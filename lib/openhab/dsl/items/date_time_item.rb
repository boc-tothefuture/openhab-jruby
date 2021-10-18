# frozen_string_literal: true

require 'forwardable'
require 'time'

require 'openhab/dsl/items/comparable_item'

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.DateTimeItem

      # Adds methods to core OpenHAB DateTimeItem type to make it more natural
      # in Ruby
      class DateTimeItem < GenericItem
        extend Forwardable
        include Comparable
        include ComparableItem

        # !@visibility private
        def ==(other)
          # need to check if we're referring to the same item before
          # forwarding to <=> (and thus checking equality with state)
          return true if equal?(other) || eql?(other)

          super
        end

        #
        # Type Coercion
        #
        # Coerce object to a DateTimeType
        #
        # @param [Types::DateTimeType, Time] other object to coerce to a
        #   DateTimeType
        #
        # @return [[Types::DateTimeType, Types::DateTimeType]]
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          return [other, nil] unless state?
          return [other, state] if other.is_a?(Types::DateTimeType) || other.respond_to?(:to_time)

          raise TypeError, "can't convert #{other.class} into #{self.class}"
        end

        # any method that exists on DateTimeType, Java's ZonedDateTime, or
        # Ruby's Time class gets forwarded to state (which will forward as
        # necessary)
        delegate ((Types::DateTimeType.instance_methods +
          java.time.ZonedDateTime.instance_methods +
          Time.instance_methods) - instance_methods) => :state

        # Time types need formatted as ISO8601
        # @!visibility private
        def format_type(command)
          return command.iso8601 if command.respond_to?(:iso8601)

          super
        end
      end
    end
  end
end
