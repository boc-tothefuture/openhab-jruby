# frozen_string_literal: true

module OpenHAB
  module DSL
    # Support for time related functions
    module Between
      # Manages Month Day Ranges
      module MonthDayRange
        include OpenHAB::Log

        # Creates a range that can be compared against MonthDay objects, strings
        # or anything responding to 'to_date' to see if they are within the range
        # @return Range object representing a MonthDay Range
        def self.range(range)
          raise ArgumentError, "Supplied object must be a range" unless range.is_a? Range

          start = MonthDay.parse(range.begin)
          ending = MonthDay.parse(range.end)

          start_range = DayOfYear.new(month_day: start, range: start..ending)
          ending_range = DayOfYear.new(month_day: ending, range: start..ending)
          logger.trace "Month Day Range Start(#{start}) - End (#{ending}) - Created from (#{range})"

          range.exclude_end? ? (start_range...ending_range) : (start_range..ending_range)
        end

        # Checks if supplied range can be converted to a month day range
        # @param [Range] range to check begin and end values of
        # @return [Boolean] Returns true if supplied range can be converted to a month day range
        def self.range?(range)
          return false unless range.is_a? Range

          MonthDay.day_of_month?(range.begin) && MonthDay.day_of_month?(range.end)
        end

        # Converts a MonthDay to a day of year
        # which is represented as a number from 1 to 732 to support comparisions when the range overlaps a year boundary
        class DayOfYear
          include Comparable
          include OpenHAB::Log
          java_import java.time.LocalDate

          attr_accessor :month_day

          # Number of days in a leap year
          DAYS_IN_YEAR = 366

          # Create a new MonthDayRange element
          # @param [MonthDay] month_day MonthDay element
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

            DayOfYear.new(month_day: MonthDay.of(next_month, next_day_of_month), range: @range)
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
            when DayOfYear then day_in_range.<=>(other.day_in_range)
            when MonthDay then self.<=>(DayOfYear.new(month_day: other, range: @range))
            when LocalDate then self.<=>(MonthDay.of(other.month_value, other.day_of_month))
            when Date then self.<=>(MonthDay.of(other.month, other.day))
            else
              return self.<=>(other.to_local_date) if other.respond_to?(:to_local_date)
              return self.<=>(other.to_date) if other.respond_to?(:to_date)

              raise "Unable to convert #{other.class} to compare to MonthDay"
            end
          end
        end
      end

      java_import java.time.Month
      # Extend Month with helper method
      class Month
        # Calcalute and memoize the maximum number of days in a year before this month
        # @return [Number] maximum nummber of days in a year before this month
        def max_days_before
          @max_days_before ||= Month.values.select { |month| month < self }.sum(&:max_length)
        end
      end

      java_import java.time.MonthDay
      # Extend MonthDay java object with some helper methods
      class MonthDay
        include OpenHAB::Log
        java_import java.time.format.DateTimeFormatter
        java_import java.time.Month

        #
        # Constructor
        #
        # @param [Integer] m month
        # @param [Integer] d day of month
        #
        # @return [Object] MonthDay object
        #
        def self.new(m:, d:) # rubocop:disable Naming/MethodParameterName
          MonthDay.of(m, d)
        end

        # Parse MonthDay string as defined with by Monthday class without leading double dash "--"
        def self.parse(string)
          logger.trace("#{self.class}.parse #{string} (#{string.class})")
          java_send :parse, [java.lang.CharSequence, java.time.format.DateTimeFormatter],
                    string.to_s,
                    DateTimeFormatter.ofPattern("[--]M-d")
        end

        # Can the supplied object be parsed into a MonthDay
        def self.day_of_month?(obj)
          /^-*[01][0-9]-[0-3]\d$/.match? obj.to_s
        end

        # Get the maximum (supports leap years) day of the year this month day could be
        def max_day_of_year
          day_of_month + month.max_days_before
        end

        # Remove -- from MonthDay string representation
        def to_s
          to_string.delete_prefix("--")
        end

        # Checks if MonthDay is between the dates of the supplied range
        # @param [Range] range to check against MonthDay
        # @return [true,false] true if the MonthDay falls within supplied range, false otherwise
        def between?(range)
          MonthDayRange.range(range).cover? self
        end

        # remove the inherited #== method to use our <=> below
        remove_method :==

        # Extends MonthDay comparison to support Strings
        # Necessary to support mixed ranges of Strings and MonthDay types
        # @return [Number, nil] -1,0,1 if other MonthDay is less than, equal to, or greater than this MonthDay
        def <=>(other)
          case other
          when String
            self.<=>(MonthDay.parse(other))
          when OpenHAB::DSL::Between::MonthDayRange::DayOfYear
            # Compare with DayOfYear and invert result
            -other.<=>(self)
          else
            super
          end
        end
      end
    end
  end
end
