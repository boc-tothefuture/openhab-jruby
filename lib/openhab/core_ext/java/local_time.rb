# frozen_string_literal: true

require_relative "time"

module OpenHAB
  module CoreExt
    module Java
      java_import java.time.LocalTime

      #
      # @example
      #   break_time = LocalTime::NOON
      #
      #   if LocalTime.now > LocalTime.of(17, 30) # comparing two LocalTime objects
      #     # do something
      #   elsif LocalTime.now < LocalTime.parse('8:30') # comparison against a string
      #     # do something
      #   end
      #   four_pm = LocalTime.parse('16:00')
      #
      # @example
      #   # Trigger security light between sunset and sunrise when motion is detected
      #   rule 'Outside Light Motion' do
      #     updated Motion_Sensor, to: OPEN
      #     run do
      #       astro = things['astro:sun:home']
      #       sunrise = astro.get_event_time('SUN_RISE', nil, nil).to_local_time
      #       sunset = astro.get_event_time('SUN_SET', nil, nil).to_local_time
      #       next if (sunrise..sunset).cover?(Time.now)
      #
      #       Security_Light.on for: 10.minutes
      #     end
      #   end
      #
      class LocalTime
        include Time

        # @!visibility private
        class << self
          #
          # Parses strings in the form "h[:mm[:ss]] [am/pm]"
          #
          # @param [String] string
          # @return [LocalTime]
          #
          def parse(string)
            format = /(am|pm)$/i.match?(string) ? "h[:mm[:ss]][ ]a" : "H[:mm[:ss]]"
            java_send(:parse, [java.lang.CharSequence, java.time.format.DateTimeFormatter],
                      string, java.time.format.DateTimeFormatterBuilder.new
                              .parse_case_insensitive.append_pattern(format).to_formatter(java.util.Locale::ENGLISH))
          end
        end

        # @param [TemporalAmount, Numeric] other
        #   If other is a Numeric, it's interpreted as seconds.
        # @return [LocalTime]
        def -(other)
          return minus(other.seconds) if other.is_a?(Numeric)
          return self if other.is_a?(Period)

          minus(other)
        end

        # @param [TemporalAmount, Numeric] other
        #   If other is a Numeric, it's interpreted as seconds.
        # @return [LocalTime]
        def +(other)
          return plus(other.seconds) if other.is_a?(Numeric)
          return self if other.is_a?(Period)

          plus(other)
        end

        #
        # Returns the next second
        #
        # Will loop back to the beginning of the day if necessary.
        #
        # @return [LocalTime]
        #
        def succ
          plus_seconds(1)
        end

        # @return [self]
        def to_local_time
          self
        end

        # @param [ZonedDateTime, nil] context
        #   A {ZonedDateTime ZonedDateTime} used to fill in missing fields
        #   during conversion. {ZonedDateTime.now} is assumed if not given.
        # @return [ZonedDateTime]
        def to_zoned_date_time(context = nil)
          context ||= ZonedDateTime.now
          context.with(self)
        end
      end
    end
  end
end

java_import java.time.LocalTime
