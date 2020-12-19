# frozen_string_literal: true

require 'java'

# Monkey patch range to support case equality of OpenHab "Numeric" Objects

module OpenHAB
  module Core
    module DSL
      module MonkeyPatch
        module Ruby
          module RangeExtensions
            def ===(other)
              return super unless [DimmerItem].any? { |type| other.is_a? type }

              cover? other.state.to_i
            end
          end
        end
      end
    end
  end
end

class Range
  prepend OpenHAB::Core::DSL::MonkeyPatch::Ruby::RangeExtensions
end
