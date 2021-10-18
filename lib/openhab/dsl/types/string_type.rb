# frozen_string_literal: true

require 'forwardable'

require_relative 'comparable_type'

module OpenHAB
  module DSL
    module Types
      java_import org.openhab.core.library.types.StringType

      #
      # Add methods to core OpenHAB StringType to make it behave as a Ruby
      # String object
      #
      class StringType
        # @!parse include Type

        extend Forwardable
        include Comparable
        include ComparableType

        #
        # Check equality without type conversion
        #
        # @return [Boolean] if the same value is represented, without type
        #   conversion
        def eql?(other)
          return false unless other.instance_of?(self.class)

          to_s.compare_to(other.to_s).zero?
        end

        #
        # Comparison
        #
        # @param [StringType, Items::StringItem, String]
        #   other object to compare to
        #
        # @return [Integer, nil] -1, 0, +1 depending on whether +other+ is
        #   less than, equal to, or greater than self
        #
        #   nil is returned if the two values are incomparable
        #
        def <=>(other) # rubocop:disable Metrics
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          if other.is_a?(Items::StringItem) ||
             (other.is_a?(Items::GroupItem) && other.base_item.is_a?(StringItem))
            return nil unless other.state?

            self <=> other.state
          elsif other.respond_to?(:to_str)
            to_str <=> other.to_str
          elsif other.respond_to?(:coerce)
            lhs, rhs = other.coerce(self)
            lhs <=> rhs
          end
        end

        #
        # Type Coercion
        #
        # Coerce object to a StringType
        #
        # @param [Items::StringItem, String] other object to coerce to a
        #   DateTimeType
        #
        # @return [[StringType, StringType]]
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          if other.is_a?(Items::StringItem)
            raise TypeError, "can't convert #{other.raw_state} into #{self.class}" unless other.state?

            [other.state, self]
          elsif other.respond_to?(:to_str)
            [String.new(other.to_str), self]
          else
            raise TypeError, "can't convert #{other.class} into #{self.class}"
          end
        end

        # any method that exists on String gets forwarded to to_s
        delegate (String.instance_methods - instance_methods) => :to_s
      end
    end
  end
end
