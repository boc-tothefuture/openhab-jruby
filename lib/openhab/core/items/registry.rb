# frozen_string_literal: true

require "singleton"

require "openhab/core/entity_lookup"
require "openhab/core/lazy_array"
require "openhab/dsl/items/builder"

module OpenHAB
  module Core
    module Items
      #
      # Provides access to all OpenHAB {Item items}, and acts like an array.
      #
      class Registry
        include LazyArray
        include Singleton

        # Fetches the named item from the the ItemRegistry
        # @param [String] name
        # @return [Item] Item from registry, nil if item missing or requested item is a Group Type
        def [](name)
          EntityLookup.lookup_item(name)
        rescue org.openhab.core.items.ItemNotFoundException
          nil
        end

        # Returns true if the given item name exists
        # @param name [String] Item name to check
        # @return [true,false] true if the item exists, false otherwise
        def key?(name)
          !$ir.getItems(name).empty?
        end
        alias_method :include?, :key?
        # @deprecated
        alias_method :has_key?, :key?

        # Explicit conversion to array
        # @return [Array]
        def to_a
          $ir.items.map { |item| Proxy.new(item) }
        end

        #
        # Enter the Item Builder DSL.
        #
        # @param (see Core::Provider.current)
        # @yield Block executed in the context of a {DSL::Items::Builder}
        # @return [Object] The return value of the block.
        #
        def build(preferred_provider = nil, &block)
          DSL::Items::BaseBuilderDSL.new(preferred_provider).instance_eval(&block)
        end

        #
        # Remove an item.
        #
        # The item must be a managed item (typically created by Ruby or in the UI).
        #
        # @param [String, Item] item_name
        # @param recursive [true, false] Remove the item's members if it's a group
        # @return [Item, nil] The removed item, if found.
        def remove(item_name, recursive: false)
          item_name = item_name.name if item_name.is_a?(Item)
          provider = Provider.registry.provider_for(item_name)
          unless provider.is_a?(org.openhab.core.common.registry.ManagedProvider)
            raise "Cannot remove item #{item_name} from non-managed provider #{provider.inspect}"
          end

          provider.remove(item_name, recursive)
        end
      end
    end
  end
end
