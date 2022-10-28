# frozen_string_literal: true

require_relative "generic_item"
require_relative "numeric_item"

module OpenHAB
  module Core
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
