# frozen_string_literal: true

require_relative "time"

module OpenHAB
  module CoreExt
    module Java
      java_import java.time.Month

      # Extensions to Month
      class Month
        #
        # Returns the next month
        #
        # Will loop back to January if necessary.
        #
        # @return [Month]
        #
        def succ
          plus(1)
        end

        # @return [LocalDate]
        def to_local_date(context = nil)
          context ||= java.time.Year.now
          year = java.time.Year.from(context)
          year.at_month_day(to_month_day)
        end

        # @return [Date]
        def to_date(context = nil)
          to_local_date(context).to_date
        end

        # @return [self]
        def to_month
          self
        end

        # @return [MonthDay]
        def to_month_day
          MonthDay.of(self, 1)
        end

        # @param [ZonedDateTime, nil] context
        #   A {ZonedDateTime} used to fill in missing fields
        #   during conversion. {ZonedDateTime.now} is assumed if not given.
        # @return [ZonedDateTime]
        def to_zoned_date_time(context = nil)
          to_local_date(context).to_zoned_date_time
        end
      end
    end
  end
end

Month = OpenHAB::CoreExt::Java::Month unless Object.const_defined?(:Month)
Month.include(OpenHAB::CoreExt::Java::Time)
