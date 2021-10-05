# frozen_string_literal: true

require 'java'
require 'openhab/core/entity_lookup'
require 'singleton'

module OpenHAB
  module DSL
    #
    # Manages OpenHAB items
    #
    module Items
      #
      # Delegates to underlying set of all OpenHAB Items, provides convenience methods
      #
      class Items
        include Enumerable
        include Singleton

        # Fetches the named item from the the ItemRegistry
        # @param [String] name
        # @return Item from registry, nil if item missing or requested item is a Group Type
        def [](name)
          OpenHAB::Core::EntityLookup.lookup_item(name)
        rescue Java::OrgOpenhabCoreItems::ItemNotFoundException
          nil
        end

        # Returns true if the given item name exists
        # @param name [String] Item name to check
        # @return [Boolean] true if the item exists, false otherwise
        def include?(name)
          !$ir.getItems(name).empty? # rubocop: disable Style/GlobalVars
        end
        alias key? include?

        # Calls the given block once for each Item, passing that Item as a
        # parameter. Returns self.
        #
        # If no block is given, an Enumerator is returned.
        def each(&block)
          # ideally we would do this lazily, but until ruby 2.7
          # there's no #eager method to convert back to a non-lazy
          # enumerator
          to_a.each(&block)
        end

        # explicit conversion to array
        # more efficient than letting Enumerable do it
        def to_a
          items = $ir.items.grep_v(Java::OrgOpenhabCoreItems::GroupItem) # rubocop:disable Style/GlobalVars
          OpenHAB::Core::EntityLookup.decorate_items(items)
        end
        # implicitly convertible to array
        alias to_ary to_a
      end

      # Fetches all non-group items from the item registry
      # @return [OpenHAB::DSL::Items::Items]
      def items
        Items.instance
      end
    end
  end
end
