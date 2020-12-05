# frozen_string_literal: true

require 'java'

module OpenHAB
  module Core
    module DSL
      module Items
        # rubocop: disable Style/GlobalVars
        class Items < SimpleDelegator
          def[](name)
            item = $ir.getItem(name)
            (item.is_a? GroupItem) ? nil : item
          end
        end

        java_import org.openhab.core.items.GroupItem
        def items
          Items.new($ir.items.reject { |item| item.is_a? GroupItem })
        end
        # rubocop: enable Style/GlobalVars
      end
    end
  end
end
