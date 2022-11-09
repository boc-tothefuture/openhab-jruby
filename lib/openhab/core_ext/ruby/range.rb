# frozen_string_literal: true

module OpenHAB
  module CoreExt
    module Ruby
      # Extensions to Range
      module Range
        def cover?(object)
          # inverted circular range
          if circular?
            return object >= self.begin || object < self.end if exclude_end?

            return object >= self.begin || object <= self.end
          end
          super
        end

        # Delegates to {#cover?} if {#circular?}
        # @!visibility private
        def ===(object)
          return cover?(object) if circular?

          super
        end

        # normal Range#each will not yield at all if begin > end
        def each
          return super unless circular?
          return to_enum(:each) unless block_given?

          val = self.begin
          loop do
            is_end = val == self.end
            break if is_end && exclude_end?

            yield val
            break if is_end

            val = val.succ
          end
        end

        #
        # Checks if this range is circular
        #
        # A circular range is one whose data type will repeat if keep you keep
        # calling #succ on it, and whose beginning is after its end.
        #
        # Used by {#cover?} to check if the value is between `end` and `begin`,
        # instead of `begin` and `end`.
        #
        # @return [true, false]
        #
        def circular?
          return false if self.begin.nil? || self.end.nil?
          return false if self.begin < self.end

          case self.begin || self.end
          when java.time.LocalTime, java.time.MonthDay, java.time.Month
            true
          else
            false
          end
        end

        ::Range.prepend(self)
      end
    end
  end
end
