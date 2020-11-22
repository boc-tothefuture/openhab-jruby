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

          # Returns the string representation of the TimeOfDay
          # @since 0.0.1
          # @return [TimeOfDay] Return current time of day advanced by one second
          def succ
            next_time = @local_time.plusSeconds(1)
            TimeOfDay.new(next_time.hour, next_time.minute, next_time.second)
          end

          # Compares one TimeOfDay to another
          # @since 0.0.1
          # @return [Number, nil] -1,0,1 if other TimeOfDay is less than, equal to, or greater than this TimeOfDay or nil if an object other than TimeOfDay is provided
          def <=>(other)
            return unless other.is_a? TimeOfDay

            @local_time.compare_to(other.local_time)
          end
        end

        MIDNIGHT = '00:00'
        NOON = '12:00'

        # Modules that refines the Ruby Range object cover? and include? methods to support TimeOfDay ranges
        module TimeOfDayRange
          NUM_SECONDS_IN_DAY = 60 * 60 * 24
          ALL_DAY = (TimeOfDay.new(h: 0, m: 0, s: 0)..TimeOfDay.new(h: 23, m: 59, s: 59)).freeze

          # Refines range to support TimeOfDay objects
          refine Range do
            # Refines range to support TimeOfDay objects
            # @since 0.0.1
            # @return [true, false] Returns true if object is between teh begin and end of the range
            def cover?(object)
              unless [self.begin, self.end, object].all? { |item| item.is_a?(TimeOfDay) || item.is_a?(String) }
                return super
              end

              range = create_range

              object = TimeOfDay.parse(object) if object.is_a? String # Convert to TimeOfDay if String
              object_second_of_day = adjust_second_of_day(object.local_time.to_second_of_day, range)

              range.cover? object_second_of_day
            end

            # Refines range to support TimeOfDay objects
            # @since 0.0.1
            # @return [true, false] Returns true if object is an element of the range, false otherwise
            def include?(object)
              unless [self.begin, self.end, object].all? { |item| item.is_a?(TimeOfDay) || item.is_a?(String) }
                return super
              end

              range = create_range

              object = TimeOfDay.parse(object) if object.is_a? String # Convert to TimeOfDay if String
              object_second_of_day = adjust_second_of_day(object.local_time.to_second_of_day, range)

              range.include? object_second_of_day
            end

            private

            def adjust_second_of_day(second_of_day, range)
              second_of_day += NUM_SECONDS_IN_DAY if second_of_day < range.begin
              second_of_day
            end

            def create_range
              start = self.begin
              ending = self.end

              start = TimeOfDay.parse(start) if start.is_a? String
              ending = TimeOfDay.parse(ending) if ending.is_a? String

              start = start.local_time.to_second_of_day
              ending = ending.local_time.to_second_of_day
              ending += NUM_SECONDS_IN_DAY if ending < start
              exclude_end? ? (start...ending) : (start..ending)
            end
          end
        end
      end
    end
  end
end
