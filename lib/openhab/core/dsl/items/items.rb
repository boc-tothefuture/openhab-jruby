# frozen_string_literal: true

require 'java'
require 'openhab/core/dsl/entities'

module OpenHAB
  module Core
    module DSL
      module Items
        # rubocop: disable Style/GlobalVars
        class Items < SimpleDelegator
          # Fetches the named item from the the ItemRegistry
          # @param [String] name
          # @return Item from registry, nil if item missing or requested item is a Group Type
          def[](name)
            item = $ir.getItem(name)
            (item.is_a? GroupItem) ? nil : item
          end
        end

        java_import org.openhab.core.items.GroupItem
        # Fetches all non-group items from the item registry
        # @return [OpenHAB::Core::DSL::Items::Items]
        def items
          Items.new(EntityLookup.decorate_items($ir.items.reject { |item| item.is_a? GroupItem }))
        end
        # rubocop: enable Style/GlobalVars
      end
    end
  end
end
