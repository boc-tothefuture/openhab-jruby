# frozen_string_literal: true

require_relative 'decimal_type'

module OpenHAB
  module DSL
    module Types
      java_import org.openhab.core.library.types.PercentType

      # global alias
      ::PercentType = PercentType

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
      end
    end
  end
end
