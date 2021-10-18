# frozen_string_literal: true

require 'openhab/dsl/items/numeric_item'

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.NumberItem

      # Adds methods to core OpenHAB NumberItem type to make it more natural in
      # Ruby
      class NumberItem < GenericItem
        include NumericItem
      end
    end
  end
end
