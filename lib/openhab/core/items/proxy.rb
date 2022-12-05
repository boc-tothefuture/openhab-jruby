# frozen_string_literal: true

require "delegate"

module OpenHAB
  module Core
    module Items
      # Class is a proxy to underlying {Item}
      # @!visibility private
      class Proxy < Delegator
        # Not really an Item, but pretends to be
        # @!parse include Item

        # @return [String]
        attr_reader :name

        #
        # Set the proxy item (called by super)
        #
        def __setobj__(item)
          @name = item.name
          # Convert name to Java version for faster lookups
          @java_name = item.name.to_java
        end

        #
        # Lookup item from item registry
        #
        def __getobj__
          r = $ir.get(@name)
          return yield if r.nil? && block_given?

          r
        end

        # @return [Module]
        def class
          return Item if __getobj__.nil?

          __getobj__.class
        end

        # @return [true, false]
        def is_a?(klass)
          obj = __getobj__
          # only claim to be a Delegator if we're backed by an actual item at the moment
          klass == Item || obj.is_a?(klass) || klass == Proxy || (!obj.nil? && super)
        end
        alias_method :kind_of?, :is_a?

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

        # @return [GroupItem::Members]
        # @raise [NoMethodError] if item is not a GroupItem, or a dummy.
        def members
          return super unless __getobj__.nil?

          GroupItem::Members.new(self)
        end

        # @return [String]
        def inspect
          return super unless __getobj__.nil?

          "#<OpenHAB::Core::Items::Proxy #{name}>"
        end

        #
        # Supports inspect from IRB when we're a dummy item.
        #
        # @return [void]
        # @!visibility private
        def pretty_print(printer)
          return super unless __getobj__.nil?

          printer.text(inspect)
        end

        # needs to return `false` if we know we're not a {GroupItem}
        def respond_to?(method, *)
          return __getobj__.nil? if method.to_sym == :members

          super
        end

        # needs to return `false` if we know we're not a {GroupItem}
        def respond_to_missing?(method, *)
          return __getobj__.nil? if method.to_sym == :members

          super
        end
      end
    end
  end
end
