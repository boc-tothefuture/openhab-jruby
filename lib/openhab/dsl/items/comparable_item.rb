# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      # Mixin for implementing the comparison operator for Item types that
      # support it
      module ComparableItem
        #
        # Comparison
        #
        # @param [GenericItem, Types::Type, Object] other object to
        #   compare to
        #
        #   If this item is +NULL+ or +UNDEF+, and +other+ is nil, they are
        #   considered equal
        #
        #   If this item is +NULL+ or +UNDEF+, and other is a {GenericItem}, they
        #   are only considered equal if the other item is in the exact same
        #   state (i.e. +NULL+ != +UNDEF+)
        #
        #   Otherwise, the state of this item is compared with +other+
        #
        # @return [Integer, nil] -1, 0, +1 depending on whether +other+ is
        #   less than, equal to, or greater than self
        #
        #   nil is returned if the two values are incomparable
        #
        def <=>(other)
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          # if we're NULL or UNDEF, implement special logic
          unless state?
            # if comparing to nil, consider ourselves equal
            return 0 if other.nil?
            # if the other object is an Item, only consider equal if we're
            # in the same _kind_ of UnDefType state
            return raw_state == other.raw_state if other.is_a?(GenericItem) && !other.state?

            # otherwise, it's a non-nil thing comparing to nil, which is undefined
            return nil
          end

          # delegate to how the state compares to the other object
          state <=> other
        end
      end
    end
  end
end
