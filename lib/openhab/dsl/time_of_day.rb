# frozen_string_literal: true

require 'openhab/log/logger'
require 'openhab/dsl/types/date_time_type'
require 'time'

module OpenHAB
  module DSL
    # Times without specific dates e.g. 6:00:00
    # @author Brian O'Connell
    # @since 0.0.1
    module TimeOfDay
      java_import java.time.LocalTime
      java_import java.time.format.DateTimeFormatterBuilder
      java_import java.util.Locale

      # Class that encapsulates a Time of Day, often viewed as hour-minute-second
      # @author Brian O'Connell
      # @since 0.0.1
      class TimeOfDay
        include Comparable

        # Immutable Java object containing Time Of Day
        # @return [Java.Time.LocalTime] reprsenting the Time Of Day
        attr_reader :local_time

        # Constructs a TimeOfDay representing the time when called
        # @since 0.0.1
        # @return [TimeOfDay] representing time when method was invoked
        def self.now
          now = LocalTime.now()
          TimeOfDay.new(h: now.hour, m: now.minute, s: now.second)
        end

        # Constructs a TimeOfDay representing midnight
        # @since 0.0.1
        # @return [TimeOfDay] representing midnight
        def self.midnight
          TimeOfDay.new(h: 0, m: 0, s: 0)
        end

        # Constructs a TimeOfDay representing noon
        # @since 0.0.1
        # @return [TimeOfDay] representing noon
        def self.noon
          TimeOfDay.new(h: 12, m: 0, s: 0)
        end

        # Constructs a TimeOfDay representing the time when called
        # @since 0.0.1
        # @param [String] string representation of TimeOfDay. Valid formats include "HH:MM:SS", "HH:MM",
        #   "H:MM", "HH", "H", "H:MM am"
        # @return [TimeOfDay] object created by parsing supplied string
        def self.parse(string)
          format = /(am|pm)$/i.match?(string) ? 'h[:mm[:ss]][ ]a' : 'H[:mm[:ss]]'
          local_time = LocalTime.parse(string, DateTimeFormatterBuilder.new
            .parseCaseInsensitive.appendPattern(format).toFormatter(Locale::ENGLISH))
          TimeOfDay.new(h: local_time.hour, m: local_time.minute, s: local_time.second)
        rescue java.time.format.DateTimeParseException => e
          raise ArgumentError, e.message
        end

        # Constructs a TimeOfDay representing the time when called
        # @since 0.0.1
        # @option opts [Number] :h Hour of the day, defaults to 0
        # @option opts [Number] :m Minute of the day, defaults to 0
        # @option opts [Number] :s Second of the day, defaults to 0
        # @return [TimeOfDay] representing time when method was invoked
        # rubocop: disable Naming/MethodParameterName
        # This method has a better feel with short parameter names
        def initialize(h: 0, m: 0, s: 0)
          @local_time = LocalTime.of(h, m, s)
          freeze
        end
        # rubocop: enable Naming/MethodParameterName

        # Returns true if the time falls within a range
        def between?(range)
          between(range).cover? self
        end

        # Returns the hour of the TimeOfDay
        # @since 0.0.1
        # @return [Number] Hour of the day, from 0 to 23
        def hour
          @local_time.hour
        end

        # Returns the minute of the TimeOfDay
        # @since 0.0.1
        # @return [Number] minute of the day, from 0 to 59
        def minute
          @local_time.minute
        end

        # Returns the second of the TimeOfDay
        # @since 0.0.1
        # @return [Number] second of the day, from 0 to 59
        def second
          @local_time.second
        end

        # Returns the string representation of the TimeOfDay
        # @since 0.0.1
        # @return [String] in any of the following formats depending on time representation HH:mm, HH:mm:ss,
        #   HH:mm:ss.SSS, HH:mm:ss.SSSSSS, HH:mm:ss.SSSSSSSSS
        def to_s
          @local_time.to_s
        end

        # Compares one TimeOfDay to another
        # @since 0.0.1
        # @return [Number, nil] -1,0,1 if other TimeOfDay is less than, equal to, or greater than this TimeOfDay
        #   or nil if an object other than TimeOfDay is provided
        def <=>(other)
          case other
          when TimeOfDay
            @local_time.compare_to(other.local_time)
          when String
            @local_time.compare_to(TimeOfDay.parse(other).local_time)
          else
            -(other <=> self)
          end
        end
      end

      # Modules that refines the Ruby Range object cover? and include? methods to support TimeOfDay ranges
      class TimeOfDayRangeElement < Numeric
        include Comparable
        include OpenHAB::Log

        NUM_SECONDS_IN_DAY = (60 * 60 * 24)

        attr_reader :sod

        def initialize(sod:, range_begin:)
          @sod = sod
          @range_begin = range_begin
          super()
        end

        # Returns the current second of day advanced by 1 second
        def succ
          TimeOfDayRangeElement.new(sod: @sod + 1, range_begin: @range_begin)
        end

        # Compares one TimeOfDayRangeElement to another
        # @since 2.4.0
        # @return [Number, nil] -1,0,1 if other is less than, equal to, or greater than this TimeOfDay
        def <=>(other)
          other_second_of_day = to_second_of_day(other)
          logger.trace do
            "SOD(#{sod}) "\
              "other SOD(#{other_second_of_day}) "\
              "Other Class (#{other.class}) "\
              "Result (#{sod <=> other_second_of_day})"
          end
          sod <=> other_second_of_day
        end

        private

        #
        # Convert object to the seconds of a day they reprsent
        #
        # @param [Object] object TimeofDay,String,Time, or TimeOfDayRangeElement to convert
        #
        # @return [Integer] seconds of day represented by supplied object
        #
        def to_second_of_day(object)
          case object
          when TimeOfDay then adjust_second_of_day(object.local_time.to_second_of_day)
          when String then adjust_second_of_day(TimeOfDay.parse(object).local_time.to_second_of_day)
          when Time, OpenHAB::DSL::Types::DateTimeType, OpenHAB::DSL::Items::DateTimeItem
            adjust_second_of_day(TimeOfDay.new(h: object.hour, m: object.min, s: object.sec)
            .local_time.to_second_of_day)
          when TimeOfDayRangeElement then object.sod
          else raise ArgumentError, 'Supplied argument cannot be converted into Time Of Day Object'
          end
        end

        def adjust_second_of_day(second_of_day)
          second_of_day += NUM_SECONDS_IN_DAY if second_of_day < @range_begin
          second_of_day
        end
      end

      # Creates a range that can be compared against time of day objects or strings
      # to see if they are within the range
      # @since 2.4.0
      # @return Range object representing a TimeOfDay Range
      module_function

      def between(range)
        raise ArgumentError, 'Supplied object must be a range' unless range.is_a? Range

        start = to_time_of_day(range.begin)
        ending = to_time_of_day(range.end)

        start_sod = start.local_time.to_second_of_day
        ending_sod = ending.local_time.to_second_of_day
        ending_sod += TimeOfDayRangeElement::NUM_SECONDS_IN_DAY if ending_sod < start_sod

        start_range = TimeOfDayRangeElement.new(sod: start_sod, range_begin: start_sod)
        ending_range = TimeOfDayRangeElement.new(sod: ending_sod, range_begin: start_sod)
        range.exclude_end? ? (start_range...ending_range) : (start_range..ending_range)
      end

      #
      # Convert object to TimeOfDay object
      #
      # @param [Object] object TimeOfDay or String to be converted
      #
      # @return [TimeOfDay] TimeOfDay created from supplied object
      #
      private_class_method def to_time_of_day(object)
        case object
        when String then TimeOfDay.parse(object)
        when Time, OpenHAB::DSL::Types::DateTimeType, OpenHAB::DSL::Items::DateTimeItem
          TimeOfDay.new(h: object.hour, m: object.min, s: object.sec)
        else object
        end
      end

      MIDNIGHT = TimeOfDay.midnight
      NOON = TimeOfDay.noon
      ALL_DAY = between(TimeOfDay.new(h: 0, m: 0, s: 0)..TimeOfDay.new(h: 23, m: 59, s: 59))
    end
  end
end
