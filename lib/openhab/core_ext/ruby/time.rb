# frozen_string_literal: true

module OpenHAB
  module CoreExt
    module Ruby
      # Extensions to Time
      module Time
        ::Time.prepend(self)

        #
        # Extends {#+} to allow adding a {java.time.temporal.TemporalAmount TemporalAmount}
        #
        # @param [java.time.temporal.TemporalAmount] other
        # @return [java.time.ZonedDateTime] If other is a {java.time.temporal.TemporalAmount TemporalAmount}
        # @return [Time] If other is a Numeric
        #
        def +(other)
          return to_zoned_date_time + other if other.is_a?(java.time.temporal.TemporalAmount)

          super
        end

        #
        # Extends {#-} to allow subtracting a {java.time.temporal.TemporalAmount TemporalAmount}
        #
        # @param [java.time.temporal.TemporalAmount] other
        # @return [java.time.ZonedDateTime] If other is a {java.time.temporal.TemporalAmount TemporalAmount}
        # @return [Time] If other is a Numeric
        #
        def -(other)
          return to_zoned_date_time - other if other.is_a?(java.time.temporal.TemporalAmount)

          super
        end

        # @return [java.time.LocalDate]
        def to_local_date(_context = nil)
          java.time.LocalDate.of(year, month, day)
        end

        # @return [java.time.LocalTime]
        def to_local_time
          java.time.LocalTime.of(hour, min, sec, nsec)
        end

        # @return [java.time.Month]
        def to_month
          java.time.Month.of(month)
        end

        # @return [java.time.MonthDay]
        def to_month_day
          java.time.MonthDay.of(month, day)
        end

        # @param [java.time.ZonedDateTime, nil] context
        #   A {java.time.ZonedDateTime ZonedDateTime} used to fill in missing fields
        #   during conversion. Not used in this class.
        # @return [java.time.ZonedDateTime]
        def to_zoned_date_time(_context = nil)
          to_java(ZonedDateTime)
        end

        #
        # Converts to a {java.time.ZonedDateTime ZonedDateTime} if `other`
        # is also convertible to a ZonedDateTime.
        #
        # @param [#to_zoned_date_time] other
        # @return [Array, nil]
        #
        def coerce(other)
          [other.to_zoned_date_time(to_zoned_date_time), self] if other.respond_to?(:to_zoned_date_time)
        end
      end
    end
  end
end
