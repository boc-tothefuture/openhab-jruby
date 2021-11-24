# frozen_string_literal: true

# OpenHAB main module
module OpenHAB
  module Core
    #
    # Manages thread local variables for access inside of blocks
    #
    module ThreadLocal
      #
      # Execute the supplied block with the supplied values set for the currently running thread
      # The previous values for each key are restored after the block is executed
      #
      # @param [Hash] Keys and values to set for running thread
      #
      def thread_local(**values)
        old_values = values.map { |key, _value| [key, Thread.current[key]] }.to_h
        values.each { |key, value| Thread.current[key] = value }
        yield
      ensure
        old_values.each { |key, value| Thread.current[key] = value }
      end
    end
  end
end
