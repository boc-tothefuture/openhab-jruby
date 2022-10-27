# frozen_string_literal: true

require "openhab/dsl/time/time_of_day"

module OpenHAB
  module DSL
    # monkey patches
    module MonkeyPatch
      # extensions to core Ruby objects
      module Ruby
        # extend String class so that it will do semantic comparisons against
        # DateTimeType and QuantityType, instead of converting the latter to
        # String and doing an exact match
        module StringExtensions
          # {include:StringExtensions}
          def ==(other)
            case other
            when Types::QuantityType,
              Types::DateTimeType,
              Items::DateTimeItem,
              Items::NumericItem,
              Between::TimeOfDay
              other == self
            else
              super
            end
          end

          # {include:StringExtensions}
          def <=>(other)
            case other
            when Types::QuantityType,
              Types::DateTimeType,
              Items::DateTimeItem,
              Items::NumericItem
              (other <=> self)&.-@()
            else
              super
            end
          end
        end
      end
    end
  end
end

String.prepend(OpenHAB::DSL::MonkeyPatch::Ruby::StringExtensions)
