# frozen_string_literal: true

class Duration
  TEMPORAL_UNITS = %i[MILLISECONDS SECONDS MINUTES HOURS].freeze

  def initialize(temporal_unit:, amount:)
    raise "Unexpected Temporal Unit: #{temporal_unit}" unless TEMPORAL_UNITS.any? { |unit| unit == temporal_unit }

    @temporal_unit = temporal_unit
    @amount = amount
  end

  def cron_expression
    case @temporal_unit
    when :SECONDS
      "*/#{@amount} * * * * ?"
    when :MINUTES
      "0 */#{@amount} * * * ?"
    when :HOURS
      "0 * */#{@amount} * * ?"
    else
      raise "Cron Expression not supported for temporal unit: #{temporal_unit}"
    end
  end

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
