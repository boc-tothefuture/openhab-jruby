# frozen_string_literal: true

require 'openhab/log/logger'

# OpenHAB main module
module OpenHAB
  module Core
    #
    # Manages thread local varaibles for access inside of blocks
    #
    module ThreadLocal
      include OpenHAB::Log

      #
      # Execute the supplied block with the supplied values set for the currently running thread
      # The previous values for each key are restored after the block is executed
      #
      # @param [Hash] values Keys and values to set for running thread, if hash is nil no values are set
      #
      def self.thread_local(**values)
        old_values = values.to_h { |key, _value| [key, Thread.current[key]] }
        values.each { |key, value| Thread.current[key] = value }
        logger.trace "Executing block with thread local context: #{values} - old context: #{old_values}"
        yield
      ensure
        old_values.each { |key, value| Thread.current[key] = value }
      end

      #
      # Execute the supplied block with the supplied values set for the currently running thread
      # The previous values for each key are restored after the block is executed
      #
      # @param [Hash] values Keys and values to set for running thread, if hash is nil no values are set
      #
      def thread_local(**values, &block)
        ThreadLocal.thread_local(**values, &block)
      end
    end
  end
end
