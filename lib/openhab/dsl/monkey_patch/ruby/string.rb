# frozen_string_literal: true

require 'openhab/dsl/types/quantity'

module OpenHAB
  module DSL
    module MonkeyPatch
      module Ruby
        #
        # Extend String class
        #
        module StringExtensions
          include OpenHAB::Core

          #
          # Compares String to another object
          #
          # @param [Object] other object to compare to
          #
          # @return [Boolean]  true if the two objects contain the same value, false otherwise
          #
          def ==(other)
            case other
            when OpenHAB::DSL::Types::Quantity, QuantityType
              other == self
            else
              super
            end
          end
        end
      end
    end
  end
end

#
# Prepend String class with comparison extensions
#
class String
  prepend OpenHAB::DSL::MonkeyPatch::Ruby::StringExtensions
end
