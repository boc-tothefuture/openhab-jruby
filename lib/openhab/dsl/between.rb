# frozen_string_literal: true

require_relative 'time/time_of_day'
require_relative 'time/month_day'

module OpenHAB
  module DSL
    # Supports between range syntax
    module Between
      # Creates a range that can be compared against time of day/month days or strings
      # to see if they are within the range
      # @since 2.4.0
      # @return Range object representing a TimeOfDay Range
      def between(range)
        raise ArgumentError, 'Supplied object must be a range' unless range.is_a? Range

        return OpenHAB::DSL::Between::MonthDayRange.range(range) if OpenHAB::DSL::Between::MonthDayRange.range?(range)

        OpenHAB::DSL::Between::TimeOfDay.between(range)
      end
    end
  end
end
