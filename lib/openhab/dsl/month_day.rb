# frozen_string_literal: true

module OpenHAB
  module DSL
    # Manages Month Day Ranges
    # @!visibility private
    module MonthDayRange
      # Creates a range that can be compared against MonthDay objects, strings
      # or anything responding to 'to_date' to see if they are within the range
      # @return Range object representing a MonthDay Range
      def self.range(range)
        raise ArgumentError, "Supplied object must be a range" unless range.is_a?(Range)

        start = java.time.MonthDay.parse(range.begin)
        ending = java.time.MonthDay.parse(range.end)

        start_range = DayOfYear.new(month_day: start, range: start..ending)
        ending_range = DayOfYear.new(month_day: ending, range: start..ending)
        logger.trace "Month Day Range Start(#{start}) - End (#{ending}) - Created from (#{range})"

        range.exclude_end? ? (start_range...ending_range) : (start_range..ending_range)
      end

      # Checks if supplied range can be converted to a month day range
      # @param [Range] range to check begin and end values of
      # @return [true,false] Returns true if supplied range can be converted to a month day range
      def self.range?(range)
        return false unless range.is_a?(Range)

        java.time.MonthDay.day_of_month?(range.begin) && java.time.MonthDay.day_of_month?(range.end)
      end

      # Converts a MonthDay to a day of year
      # which is represented as a number from 1 to 732 to support comparisions when the range overlaps a year boundary
      class DayOfYear
        include Comparable

        attr_accessor :month_day

        # Number of days in a leap year
        DAYS_IN_YEAR = 366

        # Create a new MonthDayRange element
        # @param [java.time.MonthDay] month_day MonthDay element
        # @param [Range] range Underlying MonthDay range
        #
        def initialize(month_day:, range:)
          @month_day = month_day
          @range = range
        end

        # Returns the MonthDay advanced by 1 day
        # Required by Range class
        def succ
          next_day_of_month = @month_day.day_of_month + 1
          next_month = @month_day.month_value

          if next_day_of_month > @month_day.month.max_length
            next_day_of_month = 1
            next_month = @month_day.month.plus(1).value
          end

          DayOfYear.new(month_day: java.time.MonthDay.of(next_month, next_day_of_month), range: @range)
        end

        #
        # Offset by 1 year if the range begin is greater than the range end
        # and if the month day is less than the begining of the range
        # @return [Number] 366 if the month_day should be offset by a year
        def offset
          @range.begin > @range.end && month_day < @range.begin ? DAYS_IN_YEAR : 0
        end

        #
        # Calculate the day within the range for the underlying month day
        # @return [Number] Representation of the MonthDay as a number from 1 to 732
        def day_in_range
          @day_in_range ||= month_day.max_day_of_year + offset
        end

        # Compare MonthDayRangeElement to other objects as required by Range class
        def <=>(other)
          case other
          when DayOfYear then day_in_range <=> other.day_in_range
          when java.time.MonthDay then self <=> DayOfYear.new(month_day: other, range: @range)
          when java.time.LocalDate then self <=> java.time.MonthDay.of(other.month_value, other.day_of_month)
          when Date then self <=> java.time.MonthDay.of(other.month, other.day)
          else
            return self <=> other.to_local_date if other.respond_to?(:to_local_date)
            return self <=> other.to_date if other.respond_to?(:to_date)

            raise "Unable to convert #{other.class} to compare to MonthDay"
          end
        end
      end
    end
  end
end
