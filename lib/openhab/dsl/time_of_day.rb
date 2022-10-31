# frozen_string_literal: true

module OpenHAB
  module DSL
    # Class that encapsulates a Time of Day, often viewed as hour-minute-second
    # @author Brian O'Connell
    # @!visibility private
    class TimeOfDay
      include Comparable

      # Immutable Java object containing Time Of Day
      # @return [java.time.LocalTime] reprsenting the Time Of Day
      attr_reader :local_time

      class << self
        #
        # Constructs a TimeOfDay representing the time when called
        #
        # @return [TimeOfDay] representing time when method was invoked
        #
        def now
          now = java.time.LocalTime.now()
          new(h: now.hour, m: now.minute, s: now.second)
        end

        #
        # Constructs a TimeOfDay representing midnight
        #
        # @return [TimeOfDay] representing midnight
        def midnight
          new(h: 0, m: 0, s: 0)
        end

        #
        # Constructs a TimeOfDay representing noon
        #
        # @return [TimeOfDay] representing noon
        def noon
          new(h: 12, m: 0, s: 0)
        end

        #
        # Constructs a TimeOfDay range representing an entire day.
        #
        # @return [Range] A range describing an entire day
        #
        def all_day
          between(new(h: 0, m: 0, s: 0)..new(h: 23, m: 59, s: 59))
        end

        # @param [String] string representation of TimeOfDay. Valid formats include "HH:MM:SS", "HH:MM",
        #   "H:MM", "HH", "H", "H:MM am"
        # @return [TimeOfDay] object created by parsing supplied string
        def parse(string)
          format = /(am|pm)$/i.match?(string) ? "h[:mm[:ss]][ ]a" : "H[:mm[:ss]]"
          local_time = java.time.LocalTime.parse(string, java.time.format.DateTimeFormatterBuilder.new
            .parseCaseInsensitive.appendPattern(format).toFormatter(java.util.Locale::ENGLISH))
          new(h: local_time.hour, m: local_time.minute, s: local_time.second)
        rescue java.time.format.DateTimeParseException => e
          raise ArgumentError, e.message
        end

        # Creates a range that can be compared against time of day objects or strings
        # to see if they are within the range

        # @return Range object representing a TimeOfDay Range
        def between(range)
          raise ArgumentError, "Supplied object must be a range" unless range.is_a?(Range)

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
        # @param [Object] object TimeOfDay, String, or LocalTime to be converted
        #
        # @return [TimeOfDay] TimeOfDay created from supplied object
        #
        def to_time_of_day(object)
          case object
          when String then TimeOfDay.parse(object)
          when Time, DateTimeType, DateTimeItem
            TimeOfDay.new(h: object.hour, m: object.min, s: object.sec)
          when java.time.LocalTime
            TimeOfDay.new(h: object.hour, m: object.minute, s: object.second)
          else object
          end
        end
      end

      # Constructs a TimeOfDay representing the time when called

      # @option opts [Number] :h Hour of the day, defaults to 0
      # @option opts [Number] :m Minute of the day, defaults to 0
      # @option opts [Number] :s Second of the day, defaults to 0
      # @return [TimeOfDay] representing time when method was invoked
      # rubocop: disable Naming/MethodParameterName
      # This method has a better feel with short parameter names
      def initialize(h: 0, m: 0, s: 0)
        @local_time = java.time.LocalTime.of(h, m, s)
        freeze
      end
      # rubocop: enable Naming/MethodParameterName

      # Returns true if the time falls within a range
      def between?(range)
        between(range).cover? self
      end

      # Returns the hour of the TimeOfDay

      # @return [Number] Hour of the day, from 0 to 23
      def hour
        @local_time.hour
      end

      # Returns the minute of the TimeOfDay

      # @return [Number] minute of the day, from 0 to 59
      def minute
        @local_time.minute
      end

      # Returns the second of the TimeOfDay

      # @return [Number] second of the day, from 0 to 59
      def second
        @local_time.second
      end

      # Returns the string representation of the TimeOfDay

      # @return [String] in any of the following formats depending on time representation HH:mm, HH:mm:ss,
      #   HH:mm:ss.SSS, HH:mm:ss.SSSSSS, HH:mm:ss.SSSSSSSSS
      def to_s
        @local_time.to_s
      end

      # Compares one TimeOfDay to another

      # @return [Number, nil] -1,0,1 if other TimeOfDay is less than, equal to, or greater than this TimeOfDay
      #   or nil if an object other than TimeOfDay is provided
      def <=>(other)
        logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
        case other
        when TimeOfDay then @local_time.compare_to(other.local_time)
        when String then @local_time.compare_to(TimeOfDay.parse(other).local_time)
        when java.time.LocalTime then @local_time.compare_to(other)
        else
          -(other <=> self)
        end
      end
    end

    # Module that refines the Ruby Range object cover? and include? methods to support TimeOfDay ranges
    # @!visibility private
    class TimeOfDayRangeElement < Numeric
      include Comparable

      # @!visibility private
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
      # case statement needs to compare against multiple types
      def to_second_of_day(object)
        case object
        when TimeOfDay then adjust_second_of_day(object.local_time.to_second_of_day)
        when String then adjust_second_of_day(TimeOfDay.parse(object).local_time.to_second_of_day)
        when ::Time, DateTimeType, DateTimeItem
          adjust_second_of_day(TimeOfDay.new(h: object.hour, m: object.min, s: object.sec)
          .local_time.to_second_of_day)
        when TimeOfDayRangeElement then object.sod
        else raise ArgumentError, "Supplied argument #{object.class} cannot be converted into Time Of Day Object"
        end
      end

      def adjust_second_of_day(second_of_day)
        second_of_day += NUM_SECONDS_IN_DAY if second_of_day < @range_begin
        second_of_day
      end
    end
  end
end
