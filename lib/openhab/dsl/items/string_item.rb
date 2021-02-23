# frozen_string_literal: true

require 'bigdecimal'
require 'forwardable'
require 'java'
require 'openhab/dsl/items/item_delegate'

module OpenHAB
  module DSL
    module Items
      #
      # Delegator to OpenHAB String Item
      #
      class StringItem
        extend Forwardable

        include Comparable
        extend OpenHAB::DSL::Items::ItemDelegate

        # @return [Regex] Regular expression matching blank strings
        BLANK_RE = /\A[[:space:]]*\z/.freeze
        private_constant :BLANK_RE

        def_item_delegator :@string_item

        #
        # Create a new StringItem
        #
        # @param [Java::Org::openhab::core::library::items::StringItem] string_item OpenHAB string item to delegate to
        #
        def initialize(string_item)
          @string_item = string_item

          item_missing_delegate { @string_item }
          item_missing_delegate { @string_item.state&.to_full_string&.to_s }

          super()
        end

        #
        # Convert the StringItem into a String
        #
        # @return [String] String representation of the StringItem or
        #   nil if underlying OpenHAB StringItem does not have a state
        #
        def to_str
          @string_item.state&.to_full_string&.to_s
        end

        #
        # Detect if the string is blank (not set or only whitespace)
        #
        # @return [Boolean] True if string item is not set or contains only whitespace, false otherwise
        #
        def blank?
          return true unless @string_item.state?

          @string_item.state.to_full_string.to_s.empty? || BLANK_RE.match?(self)
        end

        #
        # Check if StringItem is truthy? as per defined by library
        #
        # @return [Boolean] True if item is not in state UNDEF or NULL and value is not blank
        #
        def truthy?
          @string_item.state? && blank? == false
        end

        #
        # Compare StringItem to supplied object
        #
        # @param [Object] other object to compare to
        #
        # @return [Integer] -1,0,1 or nil depending on value supplied,
        #   nil comparison to supplied object is not possible.
        #
        def <=>(other)
          case other
          when StringItem
            @string_item.state <=> other.state
          when String
            @string_item.state.to_s <=> other
          else
            @string_item.state <=> other
          end
        end
      end
    end
  end
end
