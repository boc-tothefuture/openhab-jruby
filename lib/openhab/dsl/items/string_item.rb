# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.StringItem

      # Adds methods to core OpenHAB StringItem type to make it more natural in
      # Ruby
      class StringItem < GenericItem
      end
    end
  end
end
