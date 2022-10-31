# frozen_string_literal: true

module OpenHAB
  module Core
    module Types
      java_import org.openhab.core.types.Type

      # This is a parent interface for all {State}s and {Command}s. It
      # was introduced as many states can be commands at the same time and vice
      # versa. E.g a light can have the state {ON} or {OFF} and one can also
      # send {ON} and {OFF} as commands to the device. This duality is captured
      # by this marker interface and allows implementing classes to be both
      # state and command at the same time.
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
        # @return [[Type, Type], nil]
        #
        def coerce(other)
          logger.trace("Coercing #{self} (#{self.class}) as a request from #{other.class}")
          return [other.as(self.class), self] if other.is_a?(Type) && other.respond_to?(:as)
        end

        #
        # Check equality without type conversion
        #
        # @return [true,false] if the same value is represented, without type
        #   conversion
        def eql?(other)
          return false unless other.instance_of?(self.class)

          equals(other)
        end

        #
        # Case equality
        #
        # @return [true,false] if the values are of the same Type
        #                   or item state of the same type
        #
        def ===(other)
          logger.trace { "Type (#{self.class}) #{self} === #{other} (#{other.class})" }
          return false unless instance_of?(other.class)

          eql?(other)
        end

        #
        # Check equality, including type conversion
        #
        # @return [true,false] if the same value is represented, including
        #   type conversions
        #
        def ==(other)
          logger.trace { "(#{self.class}) #{self} == #{other} (#{other.class})" }
          return true if equal?(other)

          # i.e. ON == OFF, REFRESH == ON, ON == REFRESH
          # (RefreshType isn't really coercible)
          return equals(other) if other.instance_of?(self.class) || is_a?(RefreshType) || other.is_a?(RefreshType)

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
