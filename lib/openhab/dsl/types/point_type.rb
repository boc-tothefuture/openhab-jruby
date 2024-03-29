# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      PointType = org.openhab.core.library.types.PointType

      # global scope - required for jrubyscripting addon <= OH3.2.0
      # @!visibility private
      ::PointType = PointType if ::PointType.is_a?(java.lang.Class)

      # Adds methods to core OpenHAB PointType to make it more natural in Ruby
      class PointType
        # @!parse include PrimitiveType

        # @overload initialize(latitude, longitude, altitude)
        #   @param [DecimalType, QuantityType, StringType, Numeric] latitude
        #   @param [DecimalType, QuantityType, StringType, Numeric] longitude
        #   @param [DecimalType, QuantityType, StringType, Numeric] altitude
        def initialize(*args) # rubocop:disable Metrics
          args = from_hash(args.first.to_hash) if args.first.respond_to? :to_hash
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
          logger.trace { "(#{self.class}) #{self} == #{other} (#{other.class})" }
          if other.is_a?(Items::LocationItem) ||
             (other.is_a?(Items::GroupItem) && other.base_item.is_a?(LocationItem))
            return false unless other.state?

            self == other.state
          elsif other.respond_to?(:to_str)
            self == PointType.new(other)
          elsif other.respond_to?(:coerce)
            return false unless (lhs, rhs = other.coerce(self))

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
          lhs = coerce_single(other)
          return unless lhs

          [lhs, self]
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
        # Convert the PointType to a hash
        # @return [Hash] with keys latitude/longitude/altitude
        def to_h
          { latitude: latitude, longitude: longitude, altitude: altitude }
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
          other = coerce_single(other)
          raise TypeError, "#{other.class} can't be coerced into #{self.class}" unless other

          QuantityType.new(raw_distance_from(other), SIUnits::METRE)
        end
        alias - distance_from

        private

        # coerce an object to a PointType
        # @return [PointType]
        def coerce_single(other) # rubocop:disable Metrics
          logger.trace("Coercing #{self} as a request from #{other.class}")
          if other.is_a?(PointType)
            other
          elsif other.is_a?(Items::LocationItem)
            return unless other.state?

            other.state
          elsif other.respond_to?(:to_str)
            PointType.new(other.to_str)
          elsif other.respond_to?(:to_hash)
            PointType.new(other.to_hash)
          end
        end

        #
        # Convert hash into ordered arguments for constructor
        #
        def from_hash(hash)
          keys = [%i[lat long alt], %i[latitude longitude altitude]]
          keys.each do |key_set|
            values = hash.transform_keys(&:to_sym).values_at(*key_set)

            return *values.compact if values[0..1].all?
          end
          raise ArgumentError, "Supplied arguments (#{hash}) must contain one of the following sets #{keys}"
        end
      end
    end
  end
end
