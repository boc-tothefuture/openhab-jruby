# frozen_string_literal: true

require 'java'

module OpenHAB
  module Core
    module DSL
      # Namespace for classes and modules that handle Time Of Day - Times without specific dates e.g. 6:00:00
      # @author Brian O'Connell
      # @since 0.0.1
      module Tod
        java_import java.time.LocalTime

        # Class that encapsulates a Time of Day, often viewed as hour-minute-second
        # @author Brian O'Connell
        # @since 0.0.1
        class TimeOfDay
          include Comparable

          # Immutable Java object containing Time Of Day
          # @return [Java.Time.LocalTime] reprsenting the Time Of Day
          attr_reader :local_time

          # Constructs a TimeOfDay representing the time when called
          # @since 0.0.1
          # @return [TimeOfDay] representing time when method was invoked
          def self.now
            now = LocalTime.now()
            TimeOfDay.new(h: now.hour, m: now.minute, s: now.second)
          end

          # Constructs a TimeOfDay representing midnight
          # @since 0.0.1
          # @return [TimeOfDay] representing midnight
          def self.MIDNIGHT
            TimeOfDay.new(h: 0, m: 0, s: 0)
          end

          # Constructs a TimeOfDay representing noon
          # @since 0.0.1
          # @return [TimeOfDay] representing noon
          def self.NOON
            TimeOfDay.new(h: 12, m: 0, s: 0)
          end

          # Constructs a TimeOfDay representing the time when called
          # @since 0.0.1
          # @param [String] String representation of TimeOfDay. Valid formats include "HH:MM:SS", "HH:MM", "H:MM", "HH", "H"
          # @return [TimeOfDay] Representing supplied string
          def self.parse(string)
            # Support single digit hours
            hour, minute, second = string.split(':')
            hour = hour.rjust(2, '0') # Prepend zeros if necessary
            minute ||= '00' # Create minutes if necessary to support format "HH" or "H"
            adjusted_string = [hour, minute, second].compact.join(':') # "Put back together in format HH:MM[:SS]"

            local_time = LocalTime.parse(adjusted_string)
            TimeOfDay.new(h: local_time.hour, m: local_time.minute, s: local_time.second)
          end

          # Constructs a TimeOfDay representing the time when called
          # @since 0.0.1
          # @option opts [Number] :h Hour of the day, defaults to 0
          # @option opts [Number] :m Minute of the day, defaults to 0
          # @option opts [Number] :s Second of the day, defaults to 0
          # @return [TimeOfDay] representing time when method was invoked
          def initialize(h: 0, m: 0, s: 0)
            @local_time = LocalTime.of(h, m, s)
            freeze
          end

          # Returns the hour of the TimeOfDay
          # @since 0.0.1
          # @return [Number] Hour of the day, from 0 to 23
          def hour
            @local_time.hour
          end

          # Returns the minute of the TimeOfDay
          # @since 0.0.1
          # @return [Number] minute of the day, from 0 to 59
          def minute
            @local_time.minute
          end

          # Returns the second of the TimeOfDay
          # @since 0.0.1
          # @return [Number] second of the day, from 0 to 59
          def second
            @local_time.second
          end

          # Returns the string representation of the TimeOfDay
          # @since 0.0.1
          # @return [String] in any of the following formats depending on time representation HH:mm, HH:mm:ss, HH:mm:ss.SSS, HH:mm:ss.SSSSSS, HH:mm:ss.SSSSSSSSS
          def to_s
            @local_time.to_s
          end

          # Compares one TimeOfDay to another
          # @since 0.0.1
          # @return [Number, nil] -1,0,1 if other TimeOfDay is less than, equal to, or greater than this TimeOfDay or nil if an object other than TimeOfDay is provided
          def <=>(other)
            return unless other.is_a? TimeOfDay

            @local_time.compare_to(other.local_time)
          end
        end

        # Creates a range that can be compared against time of day objects or strings to see if they are within the range.
          # @since 2.4.0
          # @return Range object representing a TimeOfDay Range
          def between(range)
            raise 'Supplied object must be a range' unless range.is_a? Range

              start = range.begin
              ending = range.end

              start = TimeOfDay.parse(start) if start.is_a? String
              ending = TimeOfDay.parse(ending) if ending.is_a? String

              start = start.local_time.to_second_of_day
              ending = ending.local_time.to_second_of_day
              ending += NUM_SECONDS_IN_DAY if ending < start
              
              start = TimeOfDayRangeElement.new(tod: start, range_begin: start.begin)
              ending = TimeOfDayRangeElement.new(tod: ending, range_begin: start.begin)
              range.exclude_end? ? (start...ending) : (start..ending)
          end

        MIDNIGHT = '00:00'
        NOON = '12:00'
        ALL_DAY = (TimeOfDay.new(h: 0, m: 0, s: 0)..TimeOfDay.new(h: 23, m: 59, s: 59)).freeze

        # Modules that refines the Ruby Range object cover? and include? methods to support TimeOfDay ranges
        class TimeOfDayRangeElement
          include comparable

          NUM_SECONDS_IN_DAY = (60 * 60 * 24)

          def initializer(tod:, range_begin:)
            @tod = tod
            @range_begin = range_begin
          end

          # Returns the current time of day advanced by one second
          # @since 0.0.1
          # @return [TimeOfDay] Return current time of day advanced by one second
          def succ
            next_time = @tod.local_time.plusSeconds(1)
            TimeOfDay.new(next_time.hour, next_time.minute, next_time.second)
          end

          # Compares one TimeOfDayRangeElement to another
          # @since 2.4.0
          # @return [Number, nil] -1,0,1 if other TimeOfDay is less than, equal to, or greater than this TimeOfDay
          def <=>(other)
            raise 'Objects must be a TimeOfDay or String that can be parsed to TimeOfDay' unless other.is_a? TimeOfDay || other.is_a? String

            other = TimeOfDay.parse(other) if other.is_a? String # Convert to TimeOfDay if String
            other_second_of_day = adjust_second_of_day(other.local_time.to_second_of_day)

            @local_time.compare_to(other.local_time)
          end

            private

            def adjust_second_of_day(second_of_day)
              second_of_day += NUM_SECONDS_IN_DAY if second_of_day < @range_begin
              second_of_day
            end

          end
        end
      end
    end
  end
end
