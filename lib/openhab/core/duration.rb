# frozen_string_literal: true

require 'openhab/core/cron'

module OpenHAB
  module Core
    #
    # This class represents a duration of time
    #
    class Duration
      include OpenHAB::Core::Cron

      # @return [Array] of supported temperal units (milliseconds, seconds, minutes and hours)
      TEMPORAL_UNITS = %i[MILLISECONDS SECONDS MINUTES HOURS].freeze

      #
      # Create a new Duration object
      #
      # @param [Symbol] temporal_unit Unit for duration
      # @param [Integer] amount of that unit
      #
      def initialize(temporal_unit:, amount:)
        unless TEMPORAL_UNITS.include? unit == temporal_unit
          raise ArgumentError,
                "Unexpected Temporal Unit: #{temporal_unit}"
        end

        @temporal_unit = temporal_unit
        @amount = amount
      end

      #
      # Return a map
      #
      # @return [Map] Map with fields representing this duration @see OpenHAB::Core::Cron
      #
      def cron_map
        case @temporal_unit
        when :SECONDS
          cron_expression_map.merge(second: "*/#{@amount}")
        when :MINUTES
          cron_expression_map.merge(minute: "*/#{@amount}")
        when :HOURS
          cron_expression_map.merge(hour: "*/#{@amount}")
        else
          raise ArgumentError, "Cron Expression not supported for temporal unit: #{temporal_unit}"
        end
      end

      #
      # Convert the duration to milliseconds
      #
      # @return [Integer] Duration in milliseconds
      #
      def to_ms
        case @temporal_unit
        when :MILLISECONDS
          @amount
        when :SECONDS
          @amount * 1000
        when :MINUTES
          @amount * 1000 * 60
        when :HOURS
          @amount * 1000 * 60 * 60
        end
      end
    end
  end
end
