# frozen_string_literal: true

require 'openhab/dsl/types/quantity'
require 'openhab/dsl/types/datetime'
require 'openhab/dsl/items/datetime_item'

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
            when OpenHAB::DSL::Types::Quantity, QuantityType, Java::OrgOpenhabCoreLibraryTypes::StringType,
              OpenHAB::DSL::Types::DateTime, OpenHAB::DSL::Items::DateTimeItem
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
