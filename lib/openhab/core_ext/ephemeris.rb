# frozen_string_literal: true

module OpenHAB
  module CoreExt
    #
    # Forwards ephemeris helper methods to `#to_zoned_date_time` provided by
    # the mixed-in class.
    #
    # @note openHAB's built-in holiday definitions are based on _bank_
    #   holidays, so may give some unexpected results. For example, 2022-12-25
    #   is _not_ Christmas in England because it lands on a Sunday that year,
    #   so Christmas is considered to be 2022-12-26. See
    #   [the source](https://github.com/svendiedrichsen/jollyday/tree/master/src/main/resources/holidays)
    #   for exact definitions. You can always provide your own holiday
    #   definitions with {OpenHAB::DSL.holiday_file holiday_file} or
    #   {OpenHAB::DSL.holiday_file! holiday_file!}.
    #
    # @see https://www.openhab.org/docs/configuration/actions.html#ephemeris Ephemeris Action
    # @see Core::Actions::Ephemeris.holiday_name Ephemeris.holiday_name
    #
    module Ephemeris
      # (see Java::ZonedDateTime#holiday)
      def holiday(holiday_file = nil)
        to_zoned_date_time.holiday(holiday_file)
      end

      # (see Java::ZonedDateTime#holiday?)
      def holiday?(holiday_file = nil)
        to_zoned_date_time.holiday?(holiday_file)
      end

      # (see Java::ZonedDateTime#next_holiday)
      def next_holiday(holiday_file = nil)
        to_zoned_date_time.next_holiday(holiday_file)
      end

      # (see Java::ZonedDateTime#weekend?)
      def weekend?
        to_zoned_date_time.weekend?
      end

      # (see Java::ZonedDateTime#in_dayset?)
      def in_dayset?(set)
        to_zoned_date_time.in_dayset?(set)
      end

      # (see Java::ZonedDateTime#days_until)
      def days_until(holiday, holiday_file = nil)
        to_zoned_date_time.days_until(holiday, holiday_file)
      end
    end
  end
end
