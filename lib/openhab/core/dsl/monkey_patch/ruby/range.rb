# frozen_string_literal: true

require 'java'

# Monkey patch range to support case equality of OpenHab "Numeric" Objects
class Range
  java_import org.openhab.core.library.items.DimmerItem
  java_import org.openhab.core.library.items.NumberItem

  def ===(other)
    return super unless [DimmerItem, NumberItem].any? { |type| other.is_a? type }

    cover? other.state.to_i
  end
end
