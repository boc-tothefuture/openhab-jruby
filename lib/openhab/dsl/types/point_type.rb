# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      java_import org.openhab.core.library.types.PointType

      # global scope
      # @!visibility private
      ::PointType = PointType

      # Adds methods to core OpenHAB PointType to make it more natural in Ruby
      class PointType
        # @!parse include PrimitiveType

        # @param latitude [DecimalType, QuantityType, StringType, Numeric]
        # @param longitude [DecimalType, QuantityType, StringType, Numeric]
        # @param altitude [DecimalType, QuantityType, StringType, Numeric]
        def initialize(*args) # rubocop:disable Metrics
          if (2..3).cover?(args.length)
            args = args.each_with_index.map do |value, index|
              if value.is_a?(DecimalType) || value.is_a?(StringType)
                value
              elsif value.is_a?(QuantityType)
                unit = index == 2 ? Units.unit || SIUnits::METRE : Units::DEGREE_ANGLE
                DecimalType.new(value.to_unit(unit).to_big_decimal)
              elsif value.respond_to?(:to_str)
                StringType.new(value.to_str)
              elsif value.respond_to?(:to_d)
                DecimalType.new(value)
              end
            end
          end

          super(*args)
        end

        #
        # Check equality without type conversion
        #
        # @return [Boolean] if the same value is represented, without type
        #   conversion
        def eql?(other)
          return false unless other.instance_of?(self.class)

          equals(other.to_s).zero?
        end

        #
        # Check equality with type conversion
        #
        # @param [PointType, Items::LocationItem, String]
        #   other object to compare to
        #
        # @return [Boolean]
        #
        def ==(other) # rubocop:disable Metrics
          logger.trace("(#{self.class}) #{self} == #{other} (#{other.class})")
          if other.is_a?(Items::LocationItem) ||
             (other.is_a?(Items::GroupItem) && other.base_item.is_a?(LocationItem))
            return false unless other.state?

            self == other.state
          elsif other.respond_to?(:to_str)
            self == PointType.new(other)
          elsif other.respond_to?(:coerce)
            lhs, rhs = other.coerce(self)
            lhs == rhs
          end
        end

        #
        # Type Coercion
        #
        # Coerce object to a PointType
        #
        # @param [Items::LocationItem, String] other object to coerce to a
        #   PointType
        #
        # @return [[PointType, PointType]]
        #
        def coerce(other)
          [coerce_single(other), self]
        end

        # rename raw methods so we can overwrite them
        # @!visibility private
        alias raw_latitude latitude
        # .
        # @!visibility private
        alias raw_longitude longitude
        # .
        # @!visibility private
        alias raw_altitude altitude
        # .
        # @!visibility private
        alias raw_distance_from distance_from

        # @!attribute [r] latitude
        # @return [QuantityType]
        def latitude
          QuantityType.new(raw_latitude.to_big_decimal, SIUnits::DEGREE_ANGLE)
        end

        # @!attribute [r] longitude
        # @return [QuantityType]
        def longitude
          QuantityType.new(raw_longitude.to_big_decimal, SIUnits::DEGREE_ANGLE)
        end

        # @!attribute [r] altitude
        # @return [QuantityType]
        def altitude
          QuantityType.new(raw_altitude.to_big_decimal, Units::METRE)
        end

        #
        # Calculate the distance in meters from other, ignoring altitude.
        #
        # This algorithm also ignores the oblate spheroid shape of Earth and
        # assumes a perfect sphere, so results are inexact.
        #
        # @return [QuantityType]
        def distance_from(other)
          logger.trace("(#{self}).distance_from(#{other} (#{other.class})")
          QuantityType.new(raw_distance_from(coerce_single(other)), SIUnits::METRE)
        end
        alias - distance_from

        private

        # coerce an object to a PointType
        # @return [PointType]
        def coerce_single(other) # rubocop:disable Metrics/MethodLength
          logger.trace("Coercing #{self} as a request from #{other.class}")
          if other.is_a?(PointType)
            other
          elsif other.is_a?(Items::LocationItem)
            raise TypeError, "can't convert #{other.raw_state} into #{self.class}" unless other.state?

            other.state
          elsif other.respond_to?(:to_str)
            PointType.new(other.to_str)
          else
            raise TypeError, "can't convert #{other.class} into #{self.class}"
          end
        end
      end
    end
  end
end
