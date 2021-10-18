# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      # Shared method for checking item equality by delegating to state
      module ItemEquality
        # Check equality, with type conversions
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
        # @return [Boolean]
        #
        def ==(other)
          logger.trace("(#{self.class}) #{self} == #{other} (#{other.class})")
          return true if equal?(other) || eql?(other)
          return true if !state? && other.nil?

          return raw_state == other.raw_state if other.is_a?(GenericItem)

          state == other
        end
      end
    end
  end
end
