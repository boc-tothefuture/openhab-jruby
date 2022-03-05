# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Provides support for interacting with OpenHAB Persistence service
    #
    module Persistence
      module_function

      #
      # Sets a thread local variable to set the default persistence service
      # for method calls inside the block
      #
      # @param [Object] service service either as a String or a Symbol
      # @yield [] Block executed in context of the supplied persistence service
      #
      #
      def persistence(service)
        Thread.current.thread_variable_set(:persistence_service, service)
        yield
      ensure
        Thread.current.thread_variable_set(:persistence_service, nil)
      end
    end
  end
end
