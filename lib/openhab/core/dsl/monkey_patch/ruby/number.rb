# frozen_string_literal: true

require 'core/duration'

class Integer
  include OpenHAB::Core

  def seconds
    Duration.new(temporal_unit: :SECONDS, amount: self)
  end

  def milliseconds
    Duration.new(temporal_unit: :MILLISECONDS, amount: self)
  end

  def minutes
    Duration.new(temporal_unit: :MINUTES, amount: self)
  end

  def hours
    Duration.new(temporal_unit: :HOURS, amount: self)
  end

  alias second seconds
  alias millisecond milliseconds
  alias minute minutes
  alias hour hours
end
