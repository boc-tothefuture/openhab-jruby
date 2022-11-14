# frozen_string_literal: true

require "forwardable"

module OpenHAB
  module CoreExt
    module Ruby
      # Extensions to Time and DateTime
      module TimeExtensions
        extend Forwardable

        # @!visibility private
        def self.included(base)
          base.send :alias_method, :plus_without_temporal, :+
          base.send :alias_method, :+, :plus_with_temporal
          base.send :alias_method, :minus_without_temporal, :-
          base.send :alias_method, :-, :minus_with_temporal
        end

        #
        # @!method +(other)
        #
        # Extends {#+} to allow adding a {java.time.temporal.TemporalAmount TemporalAmount}
        #
        # @param [java.time.temporal.TemporalAmount] other
        # @return [ZonedDateTime] If other is a {java.time.temporal.TemporalAmount TemporalAmount}
        # @return [Time] If other is a Numeric
        #
        def plus_with_temporal(other)
          return to_zoned_date_time + other if other.is_a?(java.time.temporal.TemporalAmount)

          plus_without_temporal(other)
        end

        #
        # @!method -(other)
        #
        # Extends {#-} to allow subtracting a {java.time.temporal.TemporalAmount TemporalAmount}
        #
        # @param [java.time.temporal.TemporalAmount] other
        # @return [ZonedDateTime] If other is a {java.time.temporal.TemporalAmount TemporalAmount}
        # @return [Time] If other is a Numeric
        #
        def minus_with_temporal(other)
          return to_zoned_date_time - other if other.is_a?(java.time.temporal.TemporalAmount)

          minus_without_temporal(other)
        end

        # @return [LocalDate]
        def to_local_date(_context = nil)
          java.time.LocalDate.of(year, month, day)
        end

        # @!method to_local_time
        #   @return [LocalTime]
        def_delegator :to_zoned_date_time, :to_local_time

        # @return [Month]
        def to_month
          java.time.Month.of(month)
        end

        # @return [MonthDay]
        def to_month_day
          java.time.MonthDay.of(month, day)
        end

        # @param [ZonedDateTime, nil] context
        #   A {ZonedDateTime} used to fill in missing fields
        #   during conversion. Not used in this class.
        # @return [ZonedDateTime]
        def to_zoned_date_time(context = nil) # rubocop:disable Lint/UnusedMethodArgument
          to_java(ZonedDateTime)
        end

        #
        # Converts to a {ZonedDateTime} if `other`
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

#
# Extensions to Ruby Time
#
class Time
  include(OpenHAB::CoreExt::Ruby::TimeExtensions)
end

#
# Extensions to Ruby DateTime
#
class DateTime
  include(OpenHAB::CoreExt::Ruby::TimeExtensions)
end
