# frozen_string_literal: true

module OpenHAB
  module CoreExt
    module Ruby
      # Extensions to Date
      module Date
        ::Date.prepend(self)

        #
        # Extends {#+} to allow adding a {java.time.temporal.TemporalAmount TemporalAmount}
        #
        # @param [java.time.temporal.TemporalAmount] other
        # @return [java.time.LocalDate] If other is a {java.time.temporal.TemporalAmount TemporalAmount}
        #
        def +(other)
          return to_local_date + other if other.is_a?(java.time.temporal.TemporalAmount)

          super
        end

        #
        # Extends {#-} to allow subtracting a {java.time.temporal.TemporalAmount TemporalAmount}
        #
        # @param [java.time.temporal.TemporalAmount] other
        # @return [java.time.LocalDate] If other is a {java.time.temporal.TemporalAmount TemporalAmount}
        #
        def -(other)
          case other
          when java.time.temporal.TemporalAmount, java.time.LocalDate
            to_local_date - other
          else
            super
          end
        end

        # @return [java.time.LocalDate]
        def to_local_date(_context = nil)
          java.time.LocalDate.of(year, month, day)
        end

        # @return [java.time.Month]
        def to_month
          java.time.Month.of(month)
        end

        # @return [java.time.MonthDay]
        def to_month_day
          java.time.MonthDay.of(month, day)
        end

        # @return [java.time.ZonedDateTime]
        def to_zoned_date_time(context = nil)
          to_local_date.to_zoned_date_time(context)
        end

        # @return [Integer, nil]
        def <=>(other)
          return super if other.is_a?(self.class)

          if other.respond_to?(:coerce) && (lhs, rhs = coerce(self))
            return lhs <=> rhs
          end

          super
        end

        #
        # Convert `other` to date, if possible.
        #
        # @param [#to_date] other
        # @return [Array, nil]
        #
        def coerce(other)
          return [other.to_date, self] if other.respond_to?(:to_date)
        end

        alias_method :inspect, :to_s
      end
    end
  end
end
