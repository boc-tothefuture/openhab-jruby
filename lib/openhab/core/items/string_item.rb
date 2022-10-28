# frozen_string_literal: true

require_relative "generic_item"

module OpenHAB
  module Core
    module Items
      java_import org.openhab.core.library.items.StringItem

      # Adds methods to core OpenHAB StringItem type to make it more natural in
      # Ruby
      class StringItem < GenericItem
      end
    end
  end
end
