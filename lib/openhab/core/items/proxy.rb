# frozen_string_literal: true

require "delegate"
require "forwardable"

module OpenHAB
  module Core
    module Items
      # Class is a proxy to underlying item
      # @!visibility private
      class Proxy < Delegator
        extend Forwardable
        def_delegators :__getobj__, :class, :is_a?, :kind_of?

        #
        # Set the proxy item (called by super)
        #
        def __setobj__(item)
          # Convert name to java version for faster lookups
          @item_name = item.name.to_java
        end

        #
        # Lookup item from item registry
        #
        def __getobj__
          $ir.get(@item_name)
        end

        #
        # Need to check if `self` _or_ the delegate is an instance of the
        # given class
        #
        # So that {#==} can work
        #
        # @return [true, false]
        #
        # @!visibility private
        def instance_of?(klass)
          __getobj__.instance_of?(klass) || super
        end

        #
        # Check if delegates are equal for comparison
        #
        # Otherwise items can't be used in Java maps
        #
        # @return [true, false]
        #
        # @!visibility private
        def ==(other)
          return __getobj__ == other.__getobj__ if other.instance_of?(Proxy)

          super
        end

        #
        # Non equality comparison
        #
        # @return [true, false]
        #
        # @!visibility private
        def !=(other)
          !(self == other) # rubocop:disable Style/InverseMethods
        end
      end
    end
  end
end
