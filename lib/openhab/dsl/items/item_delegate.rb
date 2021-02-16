# frozen_string_literal: true

require 'java'
require 'openhab/log/logger'

module OpenHAB
  module DSL
    module Items
      #
      # Holds methods to delegate to items
      #
      module ItemDelegate
        include OpenHAB::Log

        #
        # Delegates methods to the object returned from the supplied block if
        #   they don't exist in the object this is included in.  If the supplied block returns nil, no delegation occurs
        # If this item is called more than once delegation occurs in the order of invocation, i.e. the object returned
        #   by the first block is delegated to if it responds to the missing method,
        #   then the second block is processed, etc.
        #
        # @param [Proc] &delegate delgegate block
        #
        #
        def item_delegate(&delegate)
          @delegates ||= []
          @delegates << delegate
        end

        #
        # Delegate missing method calls to delegates supplied to item_delgate method
        #  if no delegates exist or respond to missing method, super is invoked which will
        #  throw the appropriate method missing error
        #
        # @param [String] meth misisng method
        # @param [Array] *args Arguments to the missing method
        # @param [Proc] &block supplied to the missing method
        #
        # @return [Object] Result of missing method invocation
        #
        def method_missing(meth, *args, &block)
          logger.trace("Method (#{meth}) missing for item #{self.class}")
          delegate = delegate_for(meth)
          if delegate
            logger.trace("Delegating #{meth} to #{delegate.class}")
            delegate.__send__(meth, *args, &block)
          else
            super
          end
        end

        #
        # Checks if any of the supplied delgates respond to a specific method
        #
        # @param [String] meth method to check for
        # @param [Boolean] _include_private if private methods should be checked
        #
        # @return [Boolean] True if any delegates respond to method, false otherwise
        #
        def respond_to_missing?(meth, _include_private = false)
          logger.trace("Checking if (#{self.class}) responds to (#{meth})")
          responds = !delegate_for(meth).nil?
          logger.trace("(#{self.class}) responds to (#{meth}) (#{responds})")
          responds
        end

        private

        #
        # Find a delegate for the supplied method
        #
        # @param [String] meth method to find delegate for
        #
        # @return [Boolean] True if any method responds to the supplied delegate, false otherwise
        #
        def delegate_for(meth)
          (@delegates || []).each do |delegate_block|
            delegate = delegate_block.call(meth)
            logger.trace("Checking if delegate (#{delegate.class}) responds to (#{meth})")
            if delegate.respond_to? meth
              logger.trace("Delegate (#{delegate.class}) found for method (#{meth})")
              return delegate
            end
          end
          logger.trace("No delegate found for method (#{meth})")
          nil
        end
      end
    end
  end
end
