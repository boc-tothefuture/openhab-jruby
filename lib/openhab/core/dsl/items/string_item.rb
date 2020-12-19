# frozen_string_literal: true

require 'bigdecimal'
require 'forwardable'
require 'java'

module OpenHAB
  module Core
    module DSL
      module Items
        class StringItem
          extend Forwardable

          BLANK_RE = /\A[[:space:]]*\z/.freeze

          def_delegator :@string_item, :to_s

          def initialize(string_item)
            @string_item = string_item
            super()
          end

          def to_str
            @string_item.state&.to_full_string&.to_s
          end

          def blank?
            return true unless @string_item.state?

            @string_item.state.to_full_string.to_s.empty? || BLANK_RE.match?(self)
          end

          def truthy?
            @string_item.state? && blank? == false
          end

          def <=>(other)
            case other
            when StringItem
              @string_item.state <=> other.state
            when String
              @number_item.state.to_s <=> other
            end
          end

          # Forward missing methods to Openhab String item if they are defined
          # Then forward them to Ruby String if they are defined there
          def method_missing(meth, *args, &block)
            if @string_item.respond_to?(meth)
              @string_item.__send__(meth, *args, &block)
            elsif @string_item.state? && @string_item.state.to_full_string.to_s.respond_to?(meth)
              @string_item.state.to_full_string.to_s.__send__(meth, *args, &block)
            elsif ::Kernel.method_defined?(meth) || ::Kernel.private_method_defined?(meth)
              ::Kernel.instance_method(meth).bind_call(self, *args, &block)
            else
              super(meth, *args, &block)
            end
          end
        end
      end
    end
  end
end
