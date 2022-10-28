# frozen_string_literal: true

module OpenHAB
  module CoreExt
    module Java
      # Common extensions to Java date/time classes
      module Time
        #
        # Add other TemporalAmount or Duration object
        #
        # @param [TemporalAmount] other the TemporalAmount to be added to this ZonedDateTime object
        #
        # @return [ZonedDateTime] The resulting ZonedDateTime object after adding {other}
        #
        def +(other)
          plus(other)
        end

        #
        # Subtract other TemporalAmount or Duration object
        #
        # @param [TemporalAmount] other the TemporalAmount to be subtracted from this ZonedDateTime object
        #
        # @return [ZonedDateTime] The resulting ZonedDateTime object after subtracting {other}
        #
        def -(other)
          minus(other)
        end

        #
        # Compare against another time object
        #
        # @param [Object] other The other time object to compare against.
        #
        # @return [Integer] -1, 0, +1 depending on whether `other` is
        #   less than, equal to, or greater than self
        #
        def <=>(other)
          compare_to(other)
        rescue
          nil
        end
      end
    end
  end
end
