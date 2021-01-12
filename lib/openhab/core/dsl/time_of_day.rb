# frozen_string_literal: true

require 'java'
require 'core/log'
require 'time'
require 'date'

module OpenHAB
  module Core
    module DSL
      # Namespace for classes and modules that handle Time Of Day - Times without specific dates e.g. 6:00:00
      # @author Brian O'Connell
      # @since 0.0.1
      module Tod
        java_import java.time.LocalTime
        java_import java.time.format.DateTimeFormatter

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
          def self.midnight
            TimeOfDay.new(h: 0, m: 0, s: 0)
          end

          # Constructs a TimeOfDay representing noon
          # @since 0.0.1
          # @return [TimeOfDay] representing noon
          def self.noon
            TimeOfDay.new(h: 12, m: 0, s: 0)
          end

          # Constructs a TimeOfDay representing the time when called
          # @since 0.0.1
          # @param [String] String representation of TimeOfDay. Valid formats include "HH:MM:SS", "HH:MM", "H:MM", "HH", "H", "H:MM am"
          # @return [TimeOfDay] Representing supplied string
          def self.parse(string)
            format = /(am|pm)$/i.match?(string) ? 'h[:mm[:ss]][ ]a' : 'H[:mm[:ss]]'
            local_time = LocalTime.parse(string.downcase, DateTimeFormatter.ofPattern(format))
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
<<<<<<< HEAD
            if other.is_a? TimeOfDay
              @local_time.compare_to(other.local_time)
            else
              # Invert comparison if we don't know how to compare
              -(other <=> self)
            end
=======
            other = self.class.parse(other) if other.is_a? String
            return unless other.is_a? TimeOfDay

            @local_time.compare_to(other.local_time)
>>>>>>> main
          end
        end

        # Modules that refines the Ruby Range object cover? and include? methods to support TimeOfDay ranges
        class TimeOfDayRangeElement
          include Comparable
          include Logging

          NUM_SECONDS_IN_DAY = (60 * 60 * 24)

          attr_reader :sod

          def initialize(sod:, range_begin:)
            @sod = sod
            @range_begin = range_begin
          end

          # Returns the current second of day advanced by 1 second
          def succ
            TimeOfDayRangeElement.new(sod: @sod + 1, range_begin: @range_begin)
          end

          # Compares one TimeOfDayRangeElement to another
          # @since 2.4.0
          # @return [Number, nil] -1,0,1 if other is less than, equal to, or greater than this TimeOfDay
          def <=>(other)
            other_second_of_day = case other
                                  when TimeOfDay
                                    adjust_second_of_day(other.local_time.to_second_of_day)
                                  when String
                                    adjust_second_of_day(TimeOfDay.parse(other).local_time.to_second_of_day)
                                  when Time
                                    adjust_second_of_day(TimeOfDay.new(h: other.hour, m: other.min, s: other.sec).local_time.to_second_of_day)
                                  when TimeOfDayRangeElement
                                    other.sod
                                  else
                                    raise ArgumentError, 'Supplied argument cannot be converted into Time Of Day Object'
                                  end

            logger.trace { "SOD(#{sod}) other SOD(#{other_second_of_day}) Other Class (#{other.class}) Result (#{sod <=> other_second_of_day})" }
            sod <=> other_second_of_day
          end

          private

          def adjust_second_of_day(second_of_day)
            second_of_day += NUM_SECONDS_IN_DAY if second_of_day < @range_begin
            second_of_day
          end
        end

        # Creates a range that can be compared against time of day objects or strings to see if they are within the range.
        # @since 2.4.0
        # @return Range object representing a TimeOfDay Range
        def between(range)
          raise ArgumentError, 'Supplied object must be a range' unless range.is_a? Range

          start = range.begin
          ending = range.end

          start = TimeOfDay.parse(start) if start.is_a? String
          ending = TimeOfDay.parse(ending) if ending.is_a? String

          start_sod = start.local_time.to_second_of_day
          ending_sod = ending.local_time.to_second_of_day
          ending_sod += NUM_SECONDS_IN_DAY if ending_sod < start_sod

          start_range = TimeOfDayRangeElement.new(sod: start_sod, range_begin: start_sod)
          ending_range = TimeOfDayRangeElement.new(sod: ending_sod, range_begin: start_sod)
          range.exclude_end? ? (start_range...ending_range) : (start_range..ending_range)
        end
        module_function :between

        MIDNIGHT = TimeOfDay.midnight
        NOON = TimeOfDay.noon
        ALL_DAY = between(TimeOfDay.new(h: 0, m: 0, s: 0)..TimeOfDay.new(h: 23, m: 59, s: 59))
      end
    end
  end
end
