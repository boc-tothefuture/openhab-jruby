# frozen_string_literal: true

module OpenHAB
  module DSL
    module MonkeyPatch
      module Ruby
        # Extend Time class to allow adding/subtracting against Duration
        module TimeExtensions
          #
          # Add time offset
          #
          # @param [Numeric,Duration] other The offset to add
          #
          # @return [Time] The resulting time after adding the given offset
          #
          def +(other)
            other = to_seconds(other)
            super
          end

          #
          # Subtract time offset
          #
          # @param [Numeric,Duration] other The offset to subtract
          #
          # @return [Time] The resulting time after subtracting the given offset
          #
          def -(other)
            other = to_seconds(other)
            super
          end

          #
          # Convert to ZonedDateTime
          #
          # @return [ZonedDateTime] The current time object converted to ZonedDateTime
          #
          def to_zdt
            to_java(ZonedDateTime)
          end

          private

          #
          # Convert to floating point seconds if the given value reponds to to_nanos
          #
          # @param [Numeric,Duration] value The duration to convert into seconds.
          #
          # @return [Numeric] The number of seconds from the given value
          #
          def to_seconds(value)
            value = value.to_nanos.to_f / 1_000_000_000 if value.respond_to? :to_nanos
            value
          end
        end
      end
    end
  end
end

Time.prepend(OpenHAB::DSL::MonkeyPatch::Ruby::TimeExtensions)
