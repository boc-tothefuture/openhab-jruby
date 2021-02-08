# frozen_string_literal: true

require 'bigdecimal'
require 'forwardable'
require 'java'

module OpenHAB
  module Core
    module DSL
      module Items
        #
        # Delegator to OpenHAB String Item
        #
        class StringItem
          extend Forwardable
          include Comparable

          # @return [Regex] Regular expression matching blank strings
          BLANK_RE = /\A[[:space:]]*\z/.freeze
          private_constant :BLANK_RE

          def_delegator :@string_item, :to_s

          #
          # Create a new StringItem
          #
          # @param [Java::Org::openhab::core::library::items::StringItem] string_item OpenHAB string item to delegate to
          #
          def initialize(string_item)
            @string_item = string_item
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
            end
          end

          #
          # Forward missing methods to Openhab String Item or String representation of the item if they are defined
          #
          # @param [String] meth method name
          # @param [Array] args arguments for method
          # @param [Proc] block <description>
          #
          # @return [Object] Value from delegated method in OpenHAB StringItem or Ruby String
          #
          def method_missing(meth, *args, &block)
            if @string_item.respond_to?(meth)
              @string_item.__send__(meth, *args, &block)
            elsif @string_item.state&.to_full_string&.to_s.respond_to?(meth)
              @string_item.state.to_full_string.to_s.__send__(meth, *args, &block)
            elsif ::Kernel.method_defined?(meth) || ::Kernel.private_method_defined?(meth)
              ::Kernel.instance_method(meth).bind_call(self, *args, &block)
            else
              super(meth, *args, &block)
            end
          end

          #
          # Checks if this method responds to the missing method
          #
          # @param [String] method_name Name of the method to check
          # @param [Boolean] _include_private boolean if private methods should be checked
          #
          # @return [Boolean] true if this object will respond to the supplied method, false otherwise
          #
          def respond_to_missing?(method_name, _include_private = false)
            @string_item.respond_to?(method_name) ||
              @string_item.state&.to_full_string&.to_s.respond_to?(method_name) ||
              ::Kernel.method_defined?(method_name) ||
              ::Kernel.private_method_defined?(method_name)
          end
        end
      end
    end
  end
end
