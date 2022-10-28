# frozen_string_literal: true

module OpenHAB
  module CoreExt
    module Java
      module MonthDay
        module ClassMethods
          # Parse MonthDay string as defined with by Monthday class without leading double dash "--"
          def parse(string)
            logger.trace("#{self.class}.parse #{string} (#{string.class})")
            java_send :parse, [java.lang.CharSequence, java.time.format.DateTimeFormatter],
                      string.to_s,
                      java.time.format.DateTimeFormatter.ofPattern("[--]M-d")
          end

          # Can the supplied object be parsed into a MonthDay
          def day_of_month?(obj)
            /^-*[01][0-9]-[0-3]\d$/.match? obj.to_s
          end
        end

        def self.included(klass)
          klass.singleton_class.include(ClassMethods)
          klass.remove_method :==
        end
        java.time.MonthDay.include(self)

        # Get the maximum (supports leap years) day of the year this month day could be
        def max_day_of_year
          day_of_month + month.max_days_before
        end

        # Remove -- from MonthDay string representation
        def to_s
          to_string.delete_prefix("--")
        end

        # Checks if MonthDay is between the dates of the supplied range
        # @param [Range] range to check against MonthDay
        # @return [true,false] true if the MonthDay falls within supplied range, false otherwise
        def between?(range)
          MonthDayRange.range(range).cover? self
        end

        # Extends MonthDay comparison to support Strings
        # Necessary to support mixed ranges of Strings and MonthDay types
        # @return [Number, nil] -1,0,1 if other MonthDay is less than, equal to, or greater than this MonthDay
        def <=>(other)
          case other
          when String
            self <=> java.time.MonthDay.parse(other)
          when MonthDayRange::DayOfYear
            # Compare with DayOfYear and invert result
            -other <=> self
          else
            super
          end
        end
      end
    end
  end
end
