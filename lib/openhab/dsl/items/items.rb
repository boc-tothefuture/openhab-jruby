# frozen_string_literal: true

require 'java'
require 'openhab/core/entity_lookup'

module OpenHAB
  module DSL
    #
    # Manages OpenHAB items
    #
    module Items
      #
      # Delegates to underlying set of all OpenHAB Items, provides convenience methods
      #
      class Items < SimpleDelegator
        # Fetches the named item from the the ItemRegistry
        # @param [String] name
        # @return Item from registry, nil if item missing or requested item is a Group Type
        def[](name)
          OpenHAB::Core::EntityLookup.lookup_item(name)
        rescue Java::OrgOpenhabCoreItems::ItemNotFoundException
          nil
        end

        # Returns true if the given item name exists
        # @param name [String] Item name to check
        # @return [Boolean] true if the item exists, false otherwise
        def include?(name)
          # rubocop: disable Style/GlobalVars
          !$ir.getItems(name).empty?
          # rubocop: enable Style/GlobalVars
        end
        alias key? include?
      end

      java_import Java::OrgOpenhabCoreItems::GroupItem
      # Fetches all non-group items from the item registry
      # @return [OpenHAB::DSL::Items::Items]
      def items
        # rubocop: disable Style/GlobalVars
        Items.new(OpenHAB::Core::EntityLookup.decorate_items($ir.items.reject { |item| item.is_a? GroupItem }))
        # rubocop: enable Style/GlobalVars
      end
    end
  end
end
