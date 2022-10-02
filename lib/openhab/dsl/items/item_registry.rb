# frozen_string_literal: true

require 'singleton'

require 'openhab/core/entity_lookup'
require 'openhab/dsl/lazy_array'

module OpenHAB
  module DSL
    module Items
      module_function

      # Fetches all non-group items from the item registry
      # @return [ItemRegistry]
      def items
        OpenHAB::DSL::Support::ItemRegistry.instance
      end
    end

    # Provide supporting objects for DSL functions
    module Support
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
          !$ir.getItems(name).empty?
        end
        alias key? include?

        # Explicit conversion to array
        # @return [Array]
        def to_a
          $ir.items.map { |item| OpenHAB::Core::ItemProxy.new(item) }
        end
      end
    end
  end
end
