# frozen_string_literal: true

module OpenHAB
  module CoreExt
    module Ruby
      # extend String class so that it will do semantic comparisons against
      # DateTimeType and QuantityType, instead of converting the latter to
      # String and doing an exact match
      module String
        ::String.prepend(self)

        # Adds comparisons to {Core::Types::QuantityType}, {Core::Types::DateTimeType},
        # and {DSL::TimeOfDay}
        def ==(other)
          case other
          when Core::Types::QuantityType,
            Core::Types::DateTimeType,
            DSL::TimeOfDay
            other == self
          else
            super
          end
        end

        # Adds comparisons to {Core::Types::QuantityType}, {Core::Types::DateTimeType}
        def <=>(other)
          case other
          when Core::Types::QuantityType,
            Core::Types::DateTimeType
            (other <=> self)&.-@()
          else
            super
          end
        end
      end
    end
  end
end
