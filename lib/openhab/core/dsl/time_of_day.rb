# frozen_string_literal: true

require 'java'

module Tod
  java_import java.time.LocalTime

  # MIDNIGHT = TimeOfDay.new
  # NOON = TimeOfDay.new(hour: 12)

  #
  # start = TimeOfDay.new 6,30
  # end = TimeOfDay.new 22,30
  # Interval = Interval.new(start,end)
  # Interval = Interval.new(TimeOfDay.new(6,30), TimeOfDay.new(12,30))
  # Interval = Interval.new([6,30],[12,30])
  # "8am".tod
  # Interval.new()
  # between start..end
  # between TimeOfDay.new(21,30)..TimeOfDay.new(6)
  # between [22,30],6
  # between start: [22,30], end: 6

  class TimeOfDay
    include Comparable
    attr_reader :local_time

    def self.now
      now = LocalTime.now()
      TimeOfDay.new(now.hour, now.minute, now.second)
    end

    def initialize(hour = 0, minute = 0, second = 0)
      @local_time = LocalTime.of(hour, minute, second)
    end

    def to_s
      @local_time.to_s
    end

    def succ
      next_time = @local_time.plusSeconds(1)
      TimeOfDay.new(next_time.hour, next_time.minute, next_time.second)
    end

    def <=>(other)
      return unless other.is_a? TimeOfDay

      @local_time.compare_to(other.local_time)
    end
  end

  class Interval
    def to_tod(object)
      return object if object.is_a? TimeOfDay
      return TimeOfDay.new(*object) if object.is_a? Array

      raise 'Uknown object past to Interval Constructor'
    end

    def initialize(start_time, end_time)
      @start = to_tod(start_time)
      @end = to_tod(end_time)
    end
  end
end

module TimeOfDayRange
  include Tod

  refine Range do
    def cover?(object)
      super unless object.is_a? TimeOfDay
      raise ArgumentError, 'begin must be of type TimeOfDay' unless self.begin.is_a? TimeOfDay
      raise ArgumentError, 'end must be of type TimeOfDay' unless self.end.is_a? TimeOfDay
    end
  end
end

using TimeOfDayRange

start =  Tod::TimeOfDay.new(9)
end_time = Tod::TimeOfDay.new(3)
test_pass = Tod::TimeOfDay.new(0)
test_fail = Tod::TimeOfDay.new(8)
between = start..end_time
puts between.begin
puts between.end
puts between.cover? test_pass
puts between.include? test_pass
puts between.cover? test_fail
puts between.cover? Tod::TimeOfDay.now
puts between.cover_tod? test_pass
puts between.cover_tod? test_fail
puts (1..20).cover? 10
