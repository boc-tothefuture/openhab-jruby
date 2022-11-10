# frozen_string_literal: true

# Extensions to Integer
class Integer
  class << self
    #
    # @!macro def_duration_method
    #   @!method $1
    #
    #   Create {java.time.Duration Duration} of `self` $1
    #
    #   @return [java.time.Duration]
    #
    # @!visibility private
    def def_duration_method(unit)
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{unit}                            # def seconds
          java.time.Duration.of_#{unit}(self)  #   java.time.Duration.of_seconds(self)
        end                                    # end
      RUBY
    end

    #
    # @!macro def_period_method
    #   @!method $1
    #
    #   Create {java.time.Period Period} of `self` $1
    #
    #   @return [java.time.Period]
    #
    # @!visibility private
    def def_period_method(unit)
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{unit}                          # def days
          java.time.Period.of_#{unit}(self)  #   java.time.Period.of_days(self)
        end                                  # end
      RUBY
    end
  end

  #
  # Create {java.time.Duration Duration} of `self` milliseconds
  #
  # @return [java.time.Duration]
  #
  def in_milliseconds
    Duration.of_millis(self)
  end
  def_duration_method(:seconds)
  alias_method :second, :seconds
  def_duration_method(:minutes)
  alias_method :minute, :minutes
  def_duration_method(:hours)
  alias_method :hour, :hours
  def_period_method(:days)
  alias_method :day, :days
  def_period_method(:months)
  alias_method :month, :months
  def_period_method(:years)
  alias_method :year, :years
end

# Extensions to Float
class Float
  #
  # Create {java.time.Duration Duration} of `self` milliseconds
  #
  # @return [java.time.Duration]
  #
  def in_milliseconds
    java.time.Duration.of_nanos((self * 1_000_000).to_i)
  end

  #
  # Create {java.time.Duration Duration} of `self` seconds
  #
  # @return [java.time.Duration]
  #
  def seconds
    (self * 1000).in_milliseconds
  end
  alias_method :second, :seconds

  #
  # Create {java.time.Duration Duration} of `self` minutes
  #
  # @return [java.time.Duration]
  #
  def minutes
    (self * 60).seconds
  end
  alias_method :minute, :minutes

  #
  # Create {java.time.Duration Duration} of `self` hours
  #
  # @return [java.time.Duration]
  #
  def hours
    (self * 60).minutes
  end
  alias_method :hour, :hours

  #
  # Create {java.time.Duration Duration} of `self` days
  #
  # @return [java.time.Duration]
  #
  def days
    (self * 24).hours
  end
  alias_method :day, :days

  #
  # Create {java.time.Duration Duration} of `self` months
  #
  # @return [java.time.Duration]
  #
  def months
    (self * java.time.temporal.ChronoUnit::MONTHS.duration.to_i).seconds
  end
  alias_method :month, :months

  #
  # Create {java.time.Duration Duration} of `self` years
  #
  # @return [java.time.Duration]
  #
  def years
    (self * java.time.temporal.ChronoUnit::YEARS.duration.to_i).seconds
  end
  alias_method :year, :years
end

module OpenHAB
  module CoreExt
    module Ruby
      #
      # Extend Numeric to create quantity object
      #
      module QuantityTypeConversion
        #
        # Convert Numeric to a QuantityType
        #
        # @param [String, javax.measure.Unit] unit
        #
        # @return [Core::Types::QuantityType] `self` as a {Types::QuantityType} of the supplied Unit
        #
        def |(unit) # rubocop:disable Naming/BinaryOperatorParameterName
          unit = org.openhab.core.types.util.UnitUtils.parse_unit(unit.to_str) if unit.respond_to?(:to_str)

          return super unless unit.is_a?(javax.measure.Unit)

          Core::Types::QuantityType.new(to_d.to_java, unit)
        end
      end

      # Extensions to Numeric
      module Numeric
        include QuantityTypeConversion
        # non-Integer/Float (i.e. BigDecimal) can still be converted to Duration, via converting to float first
        extend Forwardable
        def_delegators :to_f,
                       :in_milliseconds,
                       :seconds,
                       :second,
                       :minutes,
                       :minute,
                       :hours,
                       :hour,
                       :day,
                       :days,
                       :month,
                       :months,
                       :year,
                       :years
      end

      # Integer already has #|, so we have to prepend it here
      ::Integer.prepend(QuantityTypeConversion)
      ::Numeric.include(Numeric)
    end
  end
end
