# frozen_string_literal: true

require 'singleton'

require 'openhab/core/entity_lookup'
require 'openhab/dsl/lazy_array'

module OpenHAB
  module DSL
    module Items
      #
      # Provides access to all OpenHAB items, and acts like an array.
      #
      class ItemRegistry
        include LazyArray
        include Singleton

        # Fetches the named item from the the ItemRegistry
        # @param [String] name
        # @return [GenericItem] Item from registry, nil if item missing or requested item is a Group Type
        def [](name)
          OpenHAB::Core::EntityLookup.lookup_item(name)
        rescue org.openhab.core.items.ItemNotFoundException
          nil
        end

        # Returns true if the given item name exists
        # @param name [String] Item name to check
        # @return [Boolean] true if the item exists, false otherwise
        def include?(name)
          !$ir.getItems(name).empty? # rubocop: disable Style/GlobalVars
        end
        alias key? include?

        # Explicit conversion to array
        # @return [Array]
        def to_a
          $ir.items.to_a # rubocop:disable Style/GlobalVars
        end
      end

      # Fetches all non-group items from the item registry
      # @return [ItemRegistry]
      def items
        ItemRegistry.instance
      end
    end
  end
end
