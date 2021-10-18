# frozen_string_literal: true

module OpenHAB
  module DSL
    # Comparable#== is overwritten by Type, because DecimalType etc.
    # inherits from Comparable on the Java side, so it's in the wrong place
    # in the ancestor list
    # @!visibility private
    module ComparableType
      # re-implement
      # @!visibility private
      def ==(other)
        r = self <=> other

        return false if r.nil?

        r.zero?
      end
    end
  end
end
