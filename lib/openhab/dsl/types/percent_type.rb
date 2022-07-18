# frozen_string_literal: true

require_relative 'decimal_type'

module OpenHAB
  module DSL
    module Types
      PercentType = org.openhab.core.library.types.PercentType

      # global alias - required for jrubyscripting addon <= OH3.2.0
      ::PercentType = PercentType if ::PercentType.is_a?(java.lang.Class)

      # Adds methods to core OpenHAB PercentType to make it more natural in Ruby
      class PercentType < DecimalType
        # remove the JRuby default == so that we can inherit the Ruby method
        remove_method :==

        #
        # Check if +ON+
        #
        # Note that +ON+ is defined as any value besides 0%.
        #
        # @return [Boolean]
        #
        def on?
          as(OnOffType).on?
        end

        #
        # Check if +OFF+
        #
        # Note that +OFF+ is defined as 0% exactly.
        #
        # @return [Boolean]
        #
        def off?
          as(OnOffType).off?
        end

        #
        # Check if +UP+
        #
        # Note that +UP+ is defined as 0% exactly.
        #
        # @return [Boolean]
        #
        def up?
          !!as(UpDownType)&.up?
        end

        #
        # Check if +DOWN+
        #
        # Note that +DOWN+ is defined as 100% exactly.
        #
        # @return [Boolean]
        #
        def down?
          !!as(UpDownType)&.down?
        end

        # include the %
        # @!visibility private
        def to_s
          "#{to_string}%"
        end

        #
        # Scale the value to a particular range
        #
        # @param range [Range] the range as a numeric
        # @return [Numeric] the value as a percentage of the range
        #
        def scale(range) # rubocop:disable Metrics/AbcSize
          unless range.is_a?(Range) && range.min.is_a?(Numeric) && range.max.is_a?(Numeric)
            raise ArgumentError, 'range must be a Range of Numerics'
          end

          result = (to_d * (range.max - range.min) / 100) + range.min
          case range.max
          when Integer then result.round
          when Float then result.to_f
          else result
          end
        end

        # scale the value to fit in a single byte
        #
        # @return [Integer] an integer in the range 0-255
        def to_byte
          scale(0..255)
        end
      end
    end
  end
end
