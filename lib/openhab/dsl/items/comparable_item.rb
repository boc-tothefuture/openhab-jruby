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
        # @param [GenericItem, Types::Type, Object, GenericItemObject] other object to
        #   compare to
        #
        #   When comparing GenericItemObject on either side, perform object comparison
        #   return 0 if the object is equal, or nil otherwise.
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

          if is_a?(OpenHAB::DSL::GenericItemObject) || other.is_a?(OpenHAB::DSL::GenericItemObject)
            return eql?(other) ? 0 : nil
          end

          # if we're NULL or UNDEF, implement special logic
          return nil_comparison unless state?

          # delegate to how the state compares to the other object
          state <=> other
        end

        # Special logic for NULL/UNDEF state comparison
        # @!visibility private
        def nil_comparison
          # if comparing to nil, consider ourselves equal
          return 0 if other.nil?
          # if the other object is an Item, only consider equal if we're
          # in the same _kind_ of UnDefType state
          return raw_state == other.raw_state if other.is_a?(GenericItem) && !other.state?

          # otherwise, it's a non-nil thing comparing to nil, which is undefined
          nil
        end
      end
    end
  end
end
