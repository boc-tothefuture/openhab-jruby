# frozen_string_literal: true

require 'java'

# Monkey patch range to support case equality of OpenHab "Numeric" Objects

module OpenHAB
  module DSL
    #
    # MonkeyPatch both Ruby and OpenHAB Objects to support DSL
    #
    module MonkeyPatch
      #
      # MonkeyPatch ruby object to support DSL
      #
      module Ruby
        #
        # Extensions for Range Class to support DimmerItems
        #
        module RangeExtensions
          java_import Java::OrgOpenhabCoreLibraryItems::DimmerItem

          #
          # Override range === method to support DimmerItems
          #
          # @param [Object] other object to compare for case equals
          #
          # @return [Boolean] if other is DimmerItem and state is covered by range,
          #   result from parent Range class if not DimmerItem
          #
          def ===(other)
            return super unless other.is_a? DimmerItem

            cover? other.state.to_i
          end
        end
      end
    end
  end
end

#
# Prepend Range class with RangeExtensions
#
class Range
  prepend OpenHAB::DSL::MonkeyPatch::Ruby::RangeExtensions
end
