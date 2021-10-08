# frozen_string_literal: true

module OpenHAB
  module DSL
    # common base class for array-like collections that have lookup
    # methods to avoid instantiating the elements if you only use
    # the lookup method
    #
    # your class should implement to_a
    #
    module LazyArray
      include Enumerable

      # Calls the given block once for each Thing, passing that Thing as a
      # parameter. Returns self.
      #
      # If no block is given, an Enumerator is returned.
      def each(&block)
        to_a.each(&block)
        self
      end

      # implicitly convertible to array
      def to_ary
        to_a
      end

      # delegate any other methods to the actual array
      # exclude mutating methods though
      def method_missing(method, *args, &block)
        return to_a.send(method, *args, &block) if method[-1] != '!' && Array.instance_methods.include?(method)

        super
      end

      # advertise that methods exist that would be delegated to Array
      def respond_to_missing?(method, include_private = false)
        return true if method[-1] != '!' && Array.instance_methods.include?(method.to_sym)

        super
      end
    end
  end
end
