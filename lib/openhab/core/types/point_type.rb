# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      PointType = org.openhab.core.library.types.PointType

      # {PointType} can be used for items that are dealing with GPS or location awareness functionality.
      class PointType
        # @!parse include Command, State

        # @overload initialize(latitude, longitude, altitude)
        #   @param [DecimalType, QuantityType, StringType, Numeric] latitude
        #   @param [DecimalType, QuantityType, StringType, Numeric] longitude
        #   @param [DecimalType, QuantityType, StringType, Numeric] altitude
        def initialize(*args)
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
        # @return [true,false] if the same value is represented, without type
        #   conversion
        def eql?(other)
          return false unless other.instance_of?(self.class)

          equals(other)
        end

        #
        # Check equality with type conversion
        #
        # @param [PointType, String]
        #   other object to compare to
        #
        # @return [true,false]
        #
        def ==(other)
          logger.trace { "(#{self.class}) #{self} == #{other} (#{other.class})" }
          if other.instance_of?(self.class)
            equals(other)
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
        # @param [String] other object to coerce to a
        #   PointType
        #
        # @return [[PointType, PointType], nil]
        #
        def coerce(other)
          lhs = coerce_single(other)
          return unless lhs

          [lhs, self]
        end

        # rename raw methods so we can overwrite them
        # @!visibility private
        alias_method :raw_latitude, :latitude
        # .
        # @!visibility private
        alias_method :raw_longitude, :longitude
        # .
        # @!visibility private
        alias_method :raw_altitude, :altitude
        # .
        # @!visibility private
        alias_method :raw_distance_from, :distance_from

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
        alias_method :-, :distance_from

        private

        # coerce an object to a PointType
        # @return [PointType]
        def coerce_single(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          if other.is_a?(PointType)
            other
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

# @!parse PointType = OpenHAB::Core::Types::PointType
