# frozen_string_literal: true

require 'forwardable'
require 'java'
require 'time'
require 'openhab/dsl/types/datetime'

module OpenHAB
  module DSL
    module Items
      #
      # Delegation to OpenHAB DateTime Item
      #
      # @author Anders Alfredsson
      #
      class DateTimeItem
        extend Forwardable
        include Comparable

        def_delegator :@datetime_item, :to_s

        #
        # Create a new DateTimeItem
        #
        # @param [Java::org::openhab::core::libarary::items::DateTimeItem] datetime_item Openhab DateTimeItem to
        # delegate to
        #
        def initialize(datetime_item)
          @datetime_item = datetime_item
        end

        #
        # Return an instance of DateTime that wraps the DateTimeItem's state
        #
        # @return [OpenHAB::DSL::Types::DateTime] Wrapper for the Item's state, or nil if it has no state
        #
        def to_dt
          OpenHAB::DSL::Types::DateTime.new(@datetime_item.state) if state?
        end

        #
        # Compare the Item's state to another Item or object that can be compared
        #
        # @param [Object] other Other objet to compare against
        #
        # @return [Integer] -1, 0 or 1 depending on the result of the comparison
        #
        def <=>(other)
          return unless state?

          logger.trace("Comparing self (#{self.class}) to #{other} (#{other.class})")
          other = other.to_dt if other.is_a? DateTimeItem
          to_dt <=> other
        end

        #
        # Get the time zone of the Item
        #
        # @return [String] The timezone in `[+-]hh:mm(:ss)` format or nil if the Item has no state
        #
        def zone
          to_dt.zone if state?
        end

        #
        # Check if missing method can be delegated to other contained objects
        #
        # @param [String, Symbol] meth The method name to check for
        #
        # @return [Boolean] true if DateTimeItem or DateTime responds to the method, false otherwise
        #
        def respond_to_missing?(meth, *)
          @datetime_item.respond_to?(meth) || to_dt.respond_to?(meth)
        end

        #
        # Forward missing methods to the OpenHAB Item, or a DateTime object wrapping its state
        #
        # @param [String] meth method name
        # @param [Array] args arguments for method
        # @param [Proc] block <description>
        #
        # @return [Object] Value from delegated method in OpenHAB NumberItem
        #
        def method_missing(meth, *args, &block)
          if @datetime_item.respond_to?(meth)
            @datetime_item.__send__(meth, *args, &block)
          elsif state?
            to_dt.send(meth, *args, &block)
          else
            raise NoMethodError, "undefined method `#{meth}' for #{self.class}"
          end
        end
      end
    end
  end
end
