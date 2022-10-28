# frozen_string_literal: true

require "forwardable"
require "time"

require_relative "type"

module OpenHAB
  module Core
    module Types
      DateTimeType = org.openhab.core.library.types.DateTimeType

      class DateTimeType
        # @!parse include Type

        # remove the JRuby default == so that we can inherit the Ruby method
        remove_method :==

        extend Forwardable
        include Comparable

        #
        # Regex expression to identify strings defining a time in hours, minutes and optionally seconds
        #
        TIME_ONLY_REGEX = /\A(?<hours>\d\d):(?<minutes>\d\d)(?<seconds>:\d\d)?\Z/.freeze

        #
        # Regex expression to identify strings defining a time in year, month, and day
        #
        DATE_ONLY_REGEX = /\A\d{4}-\d\d-\d\d\Z/.freeze
        private_constant :TIME_ONLY_REGEX, :DATE_ONLY_REGEX

        class << self
          #
          # Parses a String representing a time into an OpenHAB DateTimeType. First tries to parse it
          #   using java's DateTimeType's parser, then falls back to the Ruby Time.parse
          #
          # @param [String] time_string
          #
          # @return [DateTimeType]
          #
          def parse(time_string)
            time_string = "#{time_string}Z" if TIME_ONLY_REGEX.match?(time_string)
            DateTimeType.new(time_string)
          rescue java.lang.StringIndexOutOfBoundsException, java.lang.IllegalArgumentException
            # Try ruby's Time.parse if OpenHAB's DateTimeType parser fails
            begin
              DateTimeType.new(::Time.parse(time_string))
            rescue ArgumentError
              raise ArgumentError, "Unable to parse #{time_string} into a DateTimeType"
            end
          end

          # parses a String representing a duration
          #
          # for internal use
          #
          # @return [java.time.Duration]
          #
          # @!visibility private
          def parse_duration(time_string)
            # convert from common HH:MM to ISO8601 for parsing
            if (match = time_string.match(TIME_ONLY_REGEX))
              time_string = "PT#{match[:hours]}H#{match[:minutes]}M#{match[:seconds] || 0}S"
            end
            java.time.Duration.parse(time_string)
          end
        end

        # act like a ruby Time
        def_delegator :zoned_date_time, :month_value, :month
        def_delegator :zoned_date_time, :day_of_month, :mday
        def_delegator :zoned_date_time, :day_of_year, :yday
        def_delegator :zoned_date_time, :minute, :min
        def_delegator :zoned_date_time, :second, :sec
        def_delegator :zoned_date_time, :nano, :nsec
        def_delegator :zoned_date_time, :to_epoch_second, :to_i

        alias_method :day, :mday

        #
        # Create a new instance of DateTimeType
        #
        # @param value [ZonedDateTime, Time, String, Numeric]
        #
        def initialize(value = nil)
          if value.respond_to?(:to_time)
            time = value.to_time
            instant = java.time.Instant.ofEpochSecond(time.to_i, time.nsec)
            zone_id = java.time.ZoneId.of_offset("UTC", java.time.ZoneOffset.of_total_seconds(time.utc_offset))
            super(ZonedDateTime.ofInstant(instant, zone_id))
            return
          elsif value.respond_to?(:to_str)
            # strings respond_do?(:to_d), but we want to avoid that conversion
            super(value.to_str)
            return
          elsif value.respond_to?(:to_d)
            time = value.to_d
            super(ZonedDateTime.ofInstant(
              java.time.Instant.ofEpochSecond(time.to_i,
                                              ((time % 1) * 1_000_000_000).to_i),
              java.time.ZoneId.systemDefault
            ))
            return
          end

          super
        end

        #
        # Check equality without type conversion
        #
        # @return [true,false] if the same value is represented, without type
        #   conversion
        def eql?(other)
          return false unless other.instance_of?(self.class)

          zoned_date_time.compare_to(other.zoned_date_time).zero?
        end

        #
        # Comparison
        #
        # @param [DateTimeType, Time, String] other object to compare to
        #
        # @return [Integer, nil] -1, 0, +1 depending on whether `other` is
        #   less than, equal to, or greater than self
        #
        #   `nil` is returned if the two values are incomparable.
        #
        def <=>(other)
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          if other.is_a?(self.class)
            zoned_date_time.to_instant.compare_to(other.zoned_date_time.to_instant)
          elsif other.is_a?(DSL::TimeOfDay) || other.is_a?(DSL::TimeOfDayRangeElement)
            to_tod <=> other
          elsif other.respond_to?(:to_time)
            to_time <=> other.to_time
          elsif other.respond_to?(:to_str)
            time_string = other.to_str
            time_string = "#{time_string}T00:00:00#{zone}" if DATE_ONLY_REGEX.match?(time_string)
            self <=> DateTimeType.parse(time_string)
          elsif other.respond_to?(:coerce)
            return nil unless (lhs, rhs = other.coerce(self))

            lhs <=> rhs
          end
        end

        #
        # Type Coercion
        #
        # Coerce object to a DateTimeType
        #
        # @param [Time] other object to coerce to a DateTimeType
        #
        # @return [[DateTimeType, DateTimeType], nil]
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          return [DateTimeType.new(other), self] if other.respond_to?(:to_time)
        end

        #
        # Convert this DateTimeType to a ruby Time object
        #
        # @return [Time] A Time object representing the same instant and timezone
        #
        def to_time
          ::Time.at(to_i, nsec, :nsec).localtime(utc_offset)
        end

        #
        # Convert the time part of this DateTimeType to a TimeOfDay object
        #
        # @return [TimeOfDay] A TimeOfDay object representing the time
        #
        def to_time_of_day
          DSL::TimeOfDay.new(h: hour, m: minute, s: second)
        end

        alias_method :to_tod, :to_time_of_day

        #
        # Returns the value of time as a floating point number of seconds since the Epoch
        #
        # @return [Float] Number of seconds since the Epoch, with nanosecond presicion
        #
        def to_f
          zoned_date_time.to_epoch_second + (zoned_date_time.nano / 1_000_000_000)
        end

        #
        # The offset in seconds from UTC
        #
        # @return [Integer] The offset from UTC, in seconds
        #
        def utc_offset
          zoned_date_time.offset.total_seconds
        end

        #
        # Returns true if time represents a time in UTC (GMT)
        #
        # @return [true,false] true if utc_offset == 0, false otherwise
        #
        def utc?
          utc_offset.zero?
        end

        #
        # Returns an integer representing the day of the week, 0..6, with Sunday == 0.
        #
        # @return [Integer] The day of week
        #
        def wday
          zoned_date_time.day_of_week.value % 7
        end

        #
        # The timezone
        #
        # @return [String] The timezone in `[+-]hh:mm(:ss)` format (`Z` for UTC)
        #
        def zone
          zoned_date_time.zone.id
        end

        # @!visibility private
        def respond_to_missing?(method, _include_private = false)
          return true if zoned_date_time.respond_to?(method)
          return true if ::Time.instance_methods.include?(method.to_sym)

          super
        end

        #
        # Forward missing methods to the `ZonedDateTime` object or a ruby `Time`
        # object representing the same instant
        #
        def method_missing(method, *args, &block)
          return zoned_date_time.send(method, *args, &block) if zoned_date_time.respond_to?(method)
          return to_time.send(method, *args, &block) if ::Time.instance_methods.include?(method.to_sym)

          super
        end

        # Add other to self
        #
        # @param other [java.time.Duration, String, Numeric]
        #
        # @return [DateTimeType]
        def +(other)
          if other.is_a?(java.time.Duration)
            DateTimeType.new(zoned_date_time.plus(other))
          elsif other.respond_to?(:to_str)
            other = self.class.parse_duration(other.to_str)
            self + other
          elsif other.respond_to?(:to_d)
            DateTimeType.new(zoned_date_time.plusNanos((other.to_d * 1_000_000_000).to_i))
          elsif other.respond_to?(:coerce) && (lhs, rhs = other.coerce(to_d))
            lhs + rhs
          else
            raise TypeError, "\#{other.class} can't be coerced into \#{self.class}"
          end
        end

        # Subtract other from self
        #
        # if other is a Duration-like object, the result is a new
        # {DateTimeType} of duration seconds earlier in time.
        #
        # if other is a DateTime-like object, the result is a Duration
        # representing how long between the two instants in time.
        #
        # @param other [java.time.Duration, Time, String, Numeric]
        #
        # @return [DateTimeType, java.Time.Duration]
        def -(other)
          if other.is_a?(java.time.Duration)
            DateTimeType.new(zoned_date_time.minus(other))
          elsif other.respond_to?(:to_time)
            to_time - other.to_time
          elsif other.respond_to?(:to_str)
            time_string = other.to_str
            other = if TIME_ONLY_REGEX.match?(time_string)
                      self.class.parse_duration(time_string)
                    else
                      DateTimeType.parse(time_string)
                    end
            self - other
          elsif other.respond_to?(:to_d)
            DateTimeType.new(zoned_date_time.minusNanos((other.to_d * 1_000_000_000).to_i))
          elsif other.respond_to?(:coerce) && (lhs, rhs = other.coerce(to_d))
            lhs - rhs
          else
            raise TypeError, "\#{other.class} can't be coerced into \#{self.class}"
          end
        end
      end
    end
  end
end
