# frozen_string_literal: true

require_relative "time"

module OpenHAB
  module CoreExt
    module Java
      ZonedDateTime = java.time.ZonedDateTime

      # Extensions to ZonedDateTime
      class ZonedDateTime
        include Time

        class << self # rubocop:disable Lint/EmptyClass
          # @!attribute [r] now
          #   @return [ZonedDateTime]
        end

        alias_method :to_local_time, :toLocalTime
        alias_method :to_month, :month

        # @param [TemporalAmount, #to_zoned_date_time, Numeric] other
        #   If other is a Numeric, it's interpreted as seconds.
        # @return [Duration] If other responds to #to_zoned_date_time
        # @return [ZonedDateTime] If other is a TemporalAmount
        def -(other)
          if other.respond_to?(:to_zoned_date_time)
            java.time.Duration.between(other.to_zoned_date_time, self)
          elsif other.is_a?(Numeric)
            minus(other.seconds)
          else
            minus(other)
          end
        end

        # @param [TemporalAmount, Numeric] other
        #   If other is a Numeric, it's interpreted as seconds.
        # @return [ZonedDateTime]
        def +(other)
          return plus(other.seconds) if other.is_a?(Numeric)

          plus(other)
        end

        #
        # The number of seconds since the Unix epoch.
        #
        # @return [Integer]
        def to_i
          to_instant.epoch_second
        end

        #
        # The number of seconds since the Unix epoch.
        #
        # @return [Float]
        def to_f
          to_instant.to_epoch_milli / 1000.0
        end

        # @return [Date]
        def to_date
          Date.new(year, month_value, day_of_month)
        end

        # @return [LocalDate]
        def to_local_date(_context = nil)
          toLocalDate
        end

        # @return [MonthDay]
        def to_month_day
          MonthDay.of(month, day_of_month)
        end

        # This comes from JRuby

        # @!method to_time
        #   @return [Time]

        # @param [ZonedDateTime, nil] context
        #   A {ZonedDateTime} used to fill in missing fields
        #   during conversion. Not used in this class.
        # @return [self]
        def to_zoned_date_time(context = nil) # rubocop:disable Lint/UnusedMethodArgument
          self
        end

        # @return [Integer, nil]
        def <=>(other)
          # compare instants, otherwise it will differ by timezone, which we don't want
          # (use eql? if you care about that)
          if other.respond_to?(:to_zoned_date_time)
            return to_instant.compare_to(other.to_zoned_date_time(self).to_instant)
          end
          return nil unless (lhs, rhs = other.coerce(self))

          lhs <=> rhs
        end

        #
        # Converts `other` to {ZonedDateTime}, if possible
        #
        # @param [#to_zoned_date_time] other
        # @return [Array, nil]
        #
        def coerce(other)
          [other.to_zoned_date_time(self), self] if other.respond_to?(:to_zoned_date_time)
        end
      end
    end
  end
end

# @!parse ZonedDateTime = OpenHAB::CoreExt::Java::ZonedDateTime
