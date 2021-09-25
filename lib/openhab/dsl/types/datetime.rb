# frozen_string_literal: true

require 'java'
require 'forwardable'
require 'time'

module OpenHAB
  module DSL
    module Types
      #
      # Ruby implementation for OpenHAB DateTimeType
      #
      # @author Anders Alfredsson
      #
      # rubocop: disable Metrics/ClassLength
      # Disabled because this class has a single responsibility, there does not appear a logical
      # way of breaking it up into multiple classes
      class DateTime
        extend Forwardable
        include Comparable
        include OpenHAB::Log

        def_delegator :datetime, :to_s
        def_delegator :zoned_date_time, :month_value, :month
        def_delegator :zoned_date_time, :day_of_month, :mday
        def_delegator :zoned_date_time, :day_of_year, :yday
        def_delegator :zoned_date_time, :minute, :min
        def_delegator :zoned_date_time, :second, :sec
        def_delegator :zoned_date_time, :nano, :nsec
        def_delegator :zoned_date_time, :to_epoch_second, :to_i
        alias inspect to_s
        alias day mday

        java_import Java::OrgOpenhabCoreLibraryTypes::DateTimeType
        java_import java.time.ZonedDateTime
        java_import java.time.Instant
        java_import java.time.ZoneId
        java_import java.time.ZoneOffset
        java_import java.time.Duration

        #
        # Regex expression to identify strings defining a time in hours, minutes and optionally seconds
        #
        TIME_ONLY_REGEX = /\A\d\d:\d\d(:\d\d)?\Z/.freeze

        #
        # Regex expression to identify strings defining a time in hours, minutes and optionally seconds
        #
        DATE_ONLY_REGEX = /\A\d{4}-\d\d-\d\d\Z/.freeze

        attr_reader :datetime

        #
        # Create a new DateTime instance wrapping an OpenHAB DateTimeType
        #
        # @param [Java::org::openhab::core::library::types::DateTimeType] datetime The DateTimeType instance to
        #   delegate to, or an object that can be converted to a DateTimeType
        #
        def initialize(datetime)
          @datetime = case datetime
                      when DateTimeType
                        datetime
                      when ZonedDateTime
                        DateTimeType.new(datetime)
                      else
                        raise "Unexpected type #{datetime.class} provided to DateTime initializer"
                      end
        end

        #
        # Compare thes DateTime object to another
        #
        # @param [Object] other Other object to compare against
        #
        # @return [Integer] -1, 0 or 1 depending on the outcome
        #
        def <=>(other)
          if other.respond_to?(:zoned_date_time)
            return zoned_date_time.to_instant.compare_to(other.zoned_date_time.to_instant)
          end

          case other
          when TimeOfDay::TimeOfDay, TimeOfDay::TimeOfDayRangeElement then to_tod <=> other
          when String then self <=> DateTime.parse(DATE_ONLY_REGEX.match?(other) ? "#{other}'T'00:00:00#{zone}" : other)
          else
            self <=> DateTime.from(other)
          end
        end

        #
        # Adds another object to this DateTime
        #
        # @param [Object] other Object to add to this. Can be a Numeric, another DateTime/Time/DateTimeType, a
        #   Duration or a String that can be parsed into a DateTimeType or Time object
        #
        # @return [DateTime] A new DateTime object representing the result of the calculation
        #
        def +(other)
          logger.trace("Adding #{other} (#{other.class}) to #{self}")
          case other
          when Numeric then DateTime.from(to_time + other)
          when DateTime, Time then self + other.to_f
          when DateTimeType, String then self + DateTime.from(other).to_f
          when Duration then DateTime.new(zoned_date_time.plus(other))
          end
        end

        #
        # Subtracts another object from this DateTime
        #
        # @param [Object] other Object to subtract fom this. Can be a Numeric, another DateTime/Time/DateTimeType, a
        #   Duration or a String that can be parsed into a DateTimeType or Time object
        #
        # @return [DateTime, Float] A new DateTime object representing the result of the calculation, or a Float
        #   representing the time difference in seconds if the subtraction is between two time objects
        #
        def -(other)
          logger.trace("Subtracting #{other} (#{other.class}) from self")
          case other
          when Numeric then DateTime.from(to_time - other)
          when String
            dt = DateTime.parse(other)
            TIME_ONLY_REGEX.match?(other) ? self - dt.to_f : time_diff(dt)
          when Duration then DateTime.new(zoned_date_time.minus(other))
          when Time, DateTime, DateTimeType, DateTimeItem then time_diff(other)
          end
        end

        #
        # Convert this DateTime to a ruby Time object
        #
        # @return [Time] A Time object representing the same instant and timezone
        #
        def to_time
          Time.at(to_i, nsec, :nsec).localtime(utc_offset)
        end

        #
        # Convert the time part of this DateTime to a TimeOfDay object
        #
        # @return [TimeOfDay] A TimeOfDay object representing the time
        #
        def to_time_of_day
          TimeOfDay::TimeOfDay.new(h: hour, m: minute, s: second)
        end

        alias to_tod to_time_of_day

        #
        # Returns the value of time as a floating point number of seconds since the Epoch
        #
        # @return [Float] Number of seconds since the Epoch, with nanosecond presicion
        #
        def to_f
          zoned_date_time.to_epoch_second + (zoned_date_time.nano / 1_000_000_000)
        end

        #
        # The ZonedDateTime representing the state
        #
        # @return [Java::java::time::ZonedDateTime] ZonedDateTime representing the state
        #
        def zoned_date_time
          @datetime.zonedDateTime
        end

        alias to_zdt zoned_date_time

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
        # @return [Boolean] true if utc_offset == 0, false otherwise
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
        # @return [String] The timezone in `[+-]hh:mm(:ss)` format ('Z' for UTC) or nil if the Item has no state
        #
        def zone
          zoned_date_time.zone.id
        end

        #
        # Check if missing method can be delegated to other contained objects
        #
        # @param [String, Symbol] meth the method name to check for
        #
        # @return [Boolean] true if DateTimeType, ZonedDateTime or Time responds to the method, false otherwise
        #
        def respond_to_missing?(meth, *)
          @datetime.respond_to?(meth) ||
            zoned_date_time.respond_to?(meth) ||
            Time.instance_methods.include?(meth.to_sym)
        end

        #
        # Forward missing methods to the OpenHAB DateTimeType, its ZonedDateTime object or a ruby Time
        # object representing the same instant
        #
        # @param [String] meth method name
        # @param [Array] args arguments for method
        # @param [Proc] block <description>
        #
        # @return [Object] Value from delegated method in OpenHAB NumberItem
        #
        def method_missing(meth, *args, &block)
          if @datetime.respond_to?(meth)
            @datetime.__send__(meth, *args, &block)
          elsif zoned_date_time.respond_to?(meth)
            zoned_date_time.__send__(meth, *args, &block)
          elsif Time.instance_methods.include?(meth.to_sym)
            to_time.send(meth, *args, &block)
          else
            raise NoMethodError, "undefined method `#{meth}' for #{self.class}"
          end
        end

        #
        # Converts other objects to a DateTimeType
        #
        # @param [String, Numeric, Time] datetime an object that can be parsed or converted into
        #   a DateTimeType
        #
        # @return [Java::org::openhab::core::library::types::DateTimeType] Object representing the same time
        #
        def self.from(datetime)
          case datetime
          when String
            parse(datetime)
          when Numeric
            from_numeric(datetime)
          when Time
            from_time(datetime)
          else
            raise "Cannot convert #{datetime.class} to DateTime"
          end
        end

        #
        # Converts a Numeric into a DateTimeType
        #
        # @param [Numeric] numeric A Integer or Float representing the number of seconds since the epoch
        #
        # @return [Java::org::openhab::core::library::types::DateTimeType] Object representing the same time
        #
        def self.from_numeric(numeric)
          case numeric
          when Integer
            DateTime.new(ZonedDateTime.ofInstant(Instant.ofEpochSecond(datetime), ZoneId.systemDefault))
          else
            DateTime.new(ZonedDateTime.ofInstant(Instant.ofEpochSecond(datetime.to_i,
                                                                       ((datetime % 1) * 1_000_000_000).to_i),
                                                 ZoneId.systemDefault))
          end
        end

        #
        # Converts a ruby Time object to an OpenHAB DateTimeType
        #
        # @param [Time] time The Time object to be converted
        #
        # @return [Java::org::openhab::core::library::types::DateTimeType] Object representing the same time
        #
        def self.from_time(time)
          instant = Instant.ofEpochSecond(time.to_i, time.nsec)
          zone_id = ZoneId.of_offset('UTC', ZoneOffset.of_total_seconds(time.utc_offset))
          DateTime.new(ZonedDateTime.ofInstant(instant, zone_id))
        end

        #
        # Parses a string representing a time into an OpenHAB DateTimeType. First tries to parse it
        #   using the DateTimeType's parser, then falls back to the ruby Time.parse
        #
        # @param [String] time_string The string to be parsed
        #
        # @return [Java::org::openhab::core::library::types::DateTimeType] Object representing the same time
        #
        def self.parse(time_string)
          time_string += 'Z' if TIME_ONLY_REGEX.match?(time_string)
          DateTime.new(DateTimeType.new(time_string))
        rescue Java::JavaLang::StringIndexOutOfBoundsException, Java::JavaLang::IllegalArgumentException
          # Try ruby's Time.parse if OpenHAB's DateTimeType parser fails
          begin
            time = Time.parse(time_string)
            DateTime.from(time)
          rescue ArgumentError
            raise "Unable to parse #{time_string} into a DateTime"
          end
        end

        private

        #
        # Calculates the difference in time between this instance and another time object
        #
        # @param [Time, DateTime, DateTimeItem, Java::org::openhab::core::library::types::DateTimeType] time_obj
        #   The other time object to subtract from self
        #
        # @return [Float] The time difference between the two objects, in seconds
        #
        def time_diff(time_obj)
          logger.trace("Calculate time difference between #{self} and #{time_obj}")
          case time_obj
          when Time
            to_time - time_obj
          when DateTime, DateTimeItem
            self - time_obj.to_time
          when DateTimeType
            self - DateTime.new(time_obj).to_time
          end
        end
      end
    end
  end
end
# rubocop: enable Metrics/ClassLength
