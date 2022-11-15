# frozen_string_literal: true

require "singleton"

require "openhab/core/entity_lookup"
require "openhab/core/lazy_array"
require "openhab/dsl/items/builder"

module OpenHAB
  module Core
    module Items
      #
      # Provides access to all OpenHAB {GenericItem items}, and acts like an array.
      #
      class Registry
        include LazyArray
        include Singleton

        # Fetches the named item from the the ItemRegistry
        # @param [String] name
        # @return [GenericItem] Item from registry, nil if item missing or requested item is a Group Type
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

        # Explicit conversion to array
        # @return [Array]
        def to_a
          $ir.items.map { |item| Proxy.new(item) }
        end

        # Enter the Item Builder DSL.
        # @yieldparam [DSL::Items::Builder] builder
        # @return [Object] The return value of the block.
        def build(&block)
          DSL::Items::BaseBuilderDSL.new.instance_eval(&block)
        end

        # Remove an item.
        #
        # The item must have either been created by this script, or be a
        # managed item (typically created in the UI).
        #
        # @param recursive [true, false] Remove the item's members if it's a group
        # @return [GenericItem, nil] The removed item, if found.
        def remove(item_name, recursive: false)
          item_name = item_name.name if item_name.is_a?(GenericItem)
          result = DSL::Items::ItemProvider.instance.remove(item_name, recursive: recursive)
          return result if result

          $ir.remove(item_name, recursive)
        end
      end
    end
  end
end
