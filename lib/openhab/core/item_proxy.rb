# frozen_string_literal: true

require 'delegate'
require 'forwardable'

module OpenHAB
  module Core
    # Class is a proxy to underlying item
    class ItemProxy < Delegator
      extend Forwardable
      def_delegators :__getobj__, :class, :is_a?, :kind_of?, :instance_of?

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
    end
  end
end
