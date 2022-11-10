# frozen_string_literal: true

require_relative "time"

module OpenHAB
  module CoreExt
    module Java
      java_import java.time.MonthDay

      # Extensions to MonthDay
      class MonthDay
        class << self
          #
          # Parses strings in the form "M-d"
          #
          # @param [String] string
          # @return [MonthDay]
          #
          def parse(string)
            logger.trace("#{self.class}.parse #{string} (#{string.class})")
            java_send(:parse, [java.lang.CharSequence, java.time.format.DateTimeFormatter],
                      string.to_s,
                      java.time.format.DateTimeFormatter.ofPattern("[--]M-d"))
          end
        end

        # @return [String]
        def to_s
          # Remove -- from MonthDay string representation
          to_string.delete_prefix("--")
        end
        alias_method :inspect, :to_s

        # wait until we redefine #to_s
        include Time

        # @return [MonthDay]
        def +(other)
          (LocalDate.of(1900, month, day_of_month) + other).to_month_day
        end

        # @return [MonthDay]
        def -(other)
          (LocalDate.of(1900, month, day_of_month) - other).to_month_day
        end

        #
        # Returns the next day
        #
        # Will go to the next month, or loop back to January if necessary.
        #
        # @return [MonthDay]
        #
        def succ
          if day == month.max_length
            return MonthDay.of(1, 1) if month_value == 12

            return MonthDay.of(month_value + 1, 1)
          end

          MonthDay.of(month_value, day_of_month + 1)
        end

        # @return [LocalDate]
        def to_local_date(context = nil)
          context ||= java.time.Year.now
          year = java.time.Year.from(context)
          year.at_month_day(self)
        end

        # @return [self]
        def to_month_day
          self
        end

        # @param [ZonedDateTime, nil] context
        #   A {ZonedDateTime ZonedDateTime} used to fill in missing fields
        #   during conversion. {ZonedDateTime#now} is assumed if not given.
        # @return [ZonedDateTime]
        def to_zoned_date_time(context = nil)
          to_local_date(context).to_zoned_date_time(context)
        end
      end
    end
  end
end

java_import java.time.MonthDay
