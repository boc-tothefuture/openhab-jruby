# frozen_string_literal: true

require 'forwardable'

require 'openhab/dsl/items/comparable_item'

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.StringItem

      # Adds methods to core OpenHAB StringItem type to make it more natural in
      # Ruby
      class StringItem < GenericItem
        extend Forwardable
        include Comparable
        include ComparableItem

        remove_method :==

        # @return [Regex] Regular expression matching blank strings
        BLANK_RE = /\A[[:space:]]*\z/.freeze
        private_constant :BLANK_RE

        #
        # Detect if the string is blank (not set or only whitespace)
        #
        # @return [Boolean] True if string item is not set or contains only whitespace, false otherwise
        #
        def blank?
          return true unless state?

          state.empty? || BLANK_RE.match?(self)
        end

        #
        # Check if StringItem is truthy? as per defined by library
        #
        # @return [Boolean] True if item is not in state UNDEF or NULL and value is not blank
        #
        def truthy?
          state? && !blank?
        end

        # any method that exists on String gets forwarded to state (which will forward as
        # necessary)
        delegate (String.instance_methods - instance_methods) => :state
      end
    end
  end
end
