# frozen_string_literal: true

# Extensions to Date
class Date
  #
  # Extends {#+} to allow adding a {java.time.temporal.TemporalAmount TemporalAmount}
  #
  # @param [java.time.temporal.TemporalAmount] other
  # @return [java.time.LocalDate] If other is a {java.time.temporal.TemporalAmount TemporalAmount}
  #
  def plus_with_temporal(other)
    return to_local_date + other if other.is_a?(java.time.temporal.TemporalAmount)

    plus_without_temporal(other)
  end
  alias_method :plus_without_temporal, :+
  alias_method :+, :plus_with_temporal

  #
  # Extends {#-} to allow subtracting a {java.time.temporal.TemporalAmount TemporalAmount}
  #
  # @param [java.time.temporal.TemporalAmount] other
  # @return [java.time.LocalDate] If other is a {java.time.temporal.TemporalAmount TemporalAmount}
  #
  def minus_with_temporal(other)
    case other
    when java.time.temporal.TemporalAmount, java.time.LocalDate
      to_local_date - other
    else
      minus_without_temporal(other)
    end
  end
  alias_method :minus_without_temporal, :-
  alias_method :-, :minus_with_temporal

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

  # @param [java.time.ZonedDateTime, nil] context
  #   A {ZonedDateTime ZonedDateTime} used to fill in missing fields
  #   during conversion. {java.time.ZonedDateTime.now} is assumed if not given.
  # @return [java.time.ZonedDateTime]
  def to_zoned_date_time(context = nil)
    to_local_date.to_zoned_date_time(context)
  end

  # @return [Integer, nil]
  def compare_with_coercion(other)
    return compare_without_coercion(other) if other.is_a?(self.class)

    return self <=> other.to_date(self) if other.is_a?(java.time.MonthDay)

    if other.respond_to?(:coerce) && (lhs, rhs = coerce(self))
      return lhs <=> rhs
    end

    compare_without_coercion(other)
  end
  alias_method :compare_without_coercion, :<=>
  alias_method :<=>, :compare_with_coercion

  #
  # Convert `other` to Date, if possible.
  #
  # @param [#to_date] other
  # @return [Array, nil]
  #
  def coerce(other)
    return nil unless other.respond_to?(:to_date)
    return [other.to_date(self), self] if other.method(:to_date).arity == 1

    [other.to_date, self]
  end

  alias_method :inspect, :to_s
end
