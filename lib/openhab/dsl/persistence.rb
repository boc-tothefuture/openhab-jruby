# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Provides support for interacting with OpenHAB Persistence service
    #
    module Persistence
      #
      # Sets a thread local variable to set the default persistence service
      # for method calls inside the block
      #
      # @param [Object] service service either as a String or a Symbol
      # @yield [] Block executed in context of the supplied persistence service
      #
      #
      def persistence(service)
        previous_persistence = Thread.current.thread_variable_get(:persistence_service)
        Thread.current.thread_variable_set(:persistence_service, service)
        yield
      ensure
        Thread.current.thread_variable_set(:persistence_service, previous_persistence)
      end

      #
      # Sets the default persistence for the script
      #
      # @param [Object] service service either as a String or a Symbol
      #
      def def_default_persistence(service)
        Thread.current.thread_variable_set(:persistence_service, service)
      end
    end
  end
end
