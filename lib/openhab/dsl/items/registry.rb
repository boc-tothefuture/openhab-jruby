# frozen_string_literal: true

require "singleton"

require "openhab/core/entity_lookup"
require "openhab/dsl/lazy_array"
require "openhab/dsl/items/builder"

module OpenHAB
  module DSL
    module Items
      module_function

      # Fetches all items from the item registry
      # @return [Registry]
      def items
        Registry.instance
      end

      #
      # Provides access to all OpenHAB items, and acts like an array.
      #
      class Registry
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
        alias_method :key?, :include?

        # Explicit conversion to array
        # @return [Array]
        def to_a
          $ir.items.map { |item| OpenHAB::Core::ItemProxy.new(item) }
        end

        # Enter the Item Builder DSL.
        # @yield [Builder] Builder object.
        def build(&block)
          BaseBuilderDSL.new.instance_eval(&block)
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
          result = ItemProvider.instance.remove(item_name, recursive: recursive)
          return result if result

          $ir.remove(item_name, recursive)
        end
      end
    end
  end
end
