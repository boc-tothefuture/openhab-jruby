# frozen_string_literal: true

module OpenHAB
  module CoreExt
    module Java
      # Extend Month with helper method
      module Month
        # Calculate and memoize the maximum number of days in a year before this month
        # @return [Number] maximum nummber of days in a year before this month
        def max_days_before
          @max_days_before ||= Month.values.select { |month| month < self }.sum(&:max_length)
        end
      end
      java.time.Month.include(Month)
    end
  end
end
