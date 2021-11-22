# frozen_string_literal: true

module OpenHAB
  module DSL
    module Types
      java_import org.openhab.core.types.Type

      #
      # Add basic type conversion and comparison to all core OpenHAB types
      #
      module Type
        # can't alias because to_s doesn't exist on Type
        # @!visibility private
        def inspect
          to_s
        end

        #
        # Type Coercion
        #
        # Coerce object to the same Type
        #
        # @param [Type] other object to coerce to the same
        #   Type as this one
        #
        # @return [[Type, Type]]
        #
        def coerce(other)
          logger.trace("Coercing #{self} (#{self.class}) as a request from #{other.class}")
          return [other.as(self.class), self] if other.is_a?(Type) && other.respond_to?(:as)
        end

        #
        # Check equality without type conversion
        #
        # @return [Boolean] if the same value is represented, without type
        #   conversion
        def eql?(other)
          return false unless other.instance_of?(self.class)

          equals(other)
        end

        #
        # Check equality, including type conversion
        #
        # @return [Boolean] if the same value is represented, including
        #   type conversions
        #
        def ==(other) # rubocop:disable Metrics
          logger.trace("(#{self.class}) #{self} == #{other} (#{other.class})")
          return true if equal?(other)

          # i.e. ON == OFF, REFRESH == ON, ON == REFRESH
          # (RefreshType isn't really coercible)
          return equals(other) if other.instance_of?(self.class) || is_a?(RefreshType) || other.is_a?(RefreshType)

          # i.e. ON == DimmerItem (also case statements)
          return self == other.raw_state if other.is_a?(Items::GenericItem)

          if other.respond_to?(:coerce)
            begin
              return false unless (lhs, rhs = other.coerce(self))
            rescue TypeError
              # this one is a bit odd. 50 (Integer) == ON is internally
              # flipping the argument and calling this method. but it responds
              # to coerce, and then raises a TypeError (from Float???) that
              # it couldn't convert to OnOffType. it probably should have
              # returned nil. catch it and return false instead
              return false
            end

            return lhs == rhs
          end

          super
        end
      end
    end
  end
end
