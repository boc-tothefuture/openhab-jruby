# frozen_string_literal: true

module OpenHAB
  module DSL
    # Support for time related functions
    module Between
      # Manages Month Day Ranges
      module MonthDayRange
        include OpenHAB::Log

        java_import java.time.Year

        # Lambdas are used to calculate the year for the month day
        # which must happen during evaluation time to support that rules
        # creation and evaluation for execution are done in distinct phases
        @current_year = -> { return Year.now }
        @next_year = -> { return Year.now.plus_years(1) }

        class << self
          attr_reader :current_year, :next_year
        end

        # Creates a range that can be compared against MonthDay objects, strings
        # or anything responding to 'to_date' to see if they are within the range
        # @return Range object representing a MonthDay Range
        # rubocop:disable Metrics/AbcSize
        # Range method cannot be broken up cleaner
        def self.range(range)
          logger.trace "Creating MonthDay range from #{range}"
          raise ArgumentError, 'Supplied object must be a range' unless range.is_a? Range

          start = MonthDay.parse(range.begin)
          ending = MonthDay.parse(range.end)

          logger.trace "Month Day Range Start(#{start}) - End (#{ending})"

          # Wrap to next year if ending day of month is before starting day of month
          ending_year = ending < start ? next_year : current_year

          start_range = MonthDayRangeElement.new(month_day: start, year: current_year)
          ending_range = MonthDayRangeElement.new(month_day: ending, year: ending_year)
          range.exclude_end? ? (start_range...ending_range) : (start_range..ending_range)
        end
        # rubocop:enable Metrics/AbcSize

        # Checks if supplied range can be converted to a month day range
        # @param [Range] range to check begin and end values of
        # @return [Boolean] Returns true if supplied range can be converted to a month day range
        def self.range?(range)
          return false unless range.is_a? Range

          MonthDay.day_of_month?(range.begin) && MonthDay.day_of_month?(range.end)
        end

        # Represents a range element for a MonthDay object
        # The LocalDate (MonthDay + Year) is dynamically calculated to allow for
        # being used as a guard during rule evaluation
        class MonthDayRangeElement
          include Comparable
          include OpenHAB::Log
          java_import java.time.LocalDate
          java_import java.time.Year

          # Create a new MonthDayRange element
          # @param [MonthDay] MonthDay element
          # @param [Lambda] year lambda to calculate year to convert MonthDay to LocalDate
          #
          def initialize(month_day:, year:)
            @month_day = month_day
            @year = year
          end

          # Convert into a LocalDate using year lambda supplied in initializer
          def to_local_date
            @year.call.at_month_day(@month_day)
          end

          # Returns the MonthDay advanced by 1 day
          # Required by Range class
          def succ
            next_date = to_local_date.plus_days(1)
            # Handle rollover to next year
            year = -> { Year.from(next_date) }
            MonthDayRangeElement.new(month_day: MonthDay.from(next_date), year: year)
          end

          # Compare MonthDayRangeElement to other objects as required by Range class
          # rubocop:disable Metrics/AbcSize
          # Case statement needs to work against multiple types
          def <=>(other)
            case other
            when LocalDate then to_local_date.compare_to(other)
            when Date then self.<=>(LocalDate.of(other.year, other.month, other.day))
            when MonthDay then self.<=>(MonthDayRange.current_year.call.at_month_day(other))
            else
              return self.<=>(other.to_local_date) if other.respond_to? :to_local_date
              return self.<=>(other.to_date) if other.respond_to? :to_date

              raise "Unable to convert #{other.class} to compare to MonthDay"
            end
          end
          # rubocop:enable Metrics/AbcSize
        end
      end

      java_import java.time.MonthDay
      # Extend MonthDay java object with some helper methods
      class MonthDay
        include OpenHAB::Log
        java_import java.time.format.DateTimeFormatter
        # Parse MonthDay string as defined with by Monthday class without leading double dash "--"
        def self.parse(string)
          logger.trace("#{self.class}.parse #{string} (#{string.class})")
          java_send :parse, [java.lang.CharSequence, java.time.format.DateTimeFormatter],
                    string.to_s,
                    DateTimeFormatter.ofPattern('[--]M-d')
        end

        # Can the supplied object be parsed into a MonthDay
        def self.day_of_month?(obj)
          /^-*[01][0-9]-[0-3]\d$/.match? obj.to_s
        end

        # Remove -- from MonthDay string representation
        def to_s
          to_string.delete_prefix('--')
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
          else
            super
          end
        end
      end
    end
  end
end
