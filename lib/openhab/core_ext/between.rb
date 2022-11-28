# frozen_string_literal: true

module OpenHAB
  module CoreExt
    # Extensions that apply to both Date and Time classes
    module Between
      #
      # Checks whether the the object falls between the given range.
      #
      # @overload between?(min, max)
      #   @param [Object] min The minimum value to check, inclusive
      #   @param [Object] max The maximum value to check, inclusive
      #   @return [true,false]
      #
      # @overload between?(range)
      #   @param [Range] range A range to check
      #   @return [true,false]
      #
      def between?(min, max = nil)
        range = if max
                  Range.new(min, max, false)
                else
                  raise ArgumentError, "Expecting a range when given a single argument" unless min.is_a?(Range)

                  min
                end

        OpenHAB::DSL.between(range).cover?(self)
      end
    end
  end
end
