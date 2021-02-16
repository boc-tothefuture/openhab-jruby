# frozen_string_literal: true

module OpenHAB
  module DSL
    module MonkeyPatch
      module Ruby
        #
        # Extend Time to make to_s return string parseable by OpenHAB
        #
        module TimeExtensions
          include OpenHAB::Core

          #
          # Convert to ISO 8601 format
          #
          # @return [Java::JavaTime::Duration] Duration with number of units from self
          #
          def to_s
            strftime '%FT%T.%N%:z'
          end
        end
      end
    end
  end
end

#
# Extend Time class with to_s method
#
class Time
  prepend OpenHAB::DSL::MonkeyPatch::Ruby::TimeExtensions
end
