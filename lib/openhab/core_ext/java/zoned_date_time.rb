# frozen_string_literal: true

require_relative "time"

module OpenHAB
  module CoreExt
    module Java
      #
      # Extend ZonedDateTime class to support arithmetic operators
      #
      module ZonedDateTime
        include Time

        # apply meta-programming methods to prepending class
        # @!visibility private
        def self.prepended(klass)
          # remove the JRuby default == so that we can inherit the Ruby method
          klass.remove_method :==
        end

        java.time.ZonedDateTime.prepend(self)

        #
        # Comparison
        #
        # @param [ZonedDateTime,::Time] other object to compare to
        #
        # @return [Integer] -1, 0, +1 depending on whether `other` is
        #   less than, equal to, or greater than self
        #
        def compare_to(other)
          logger.trace("(#{self.class}) #{self} compare_to #{other} (#{other.class})")
          other = other.to_java(::ZonedDateTime) if other.is_a?(::Time)
          super
        end
      end
    end
  end
end
