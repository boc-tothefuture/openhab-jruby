# frozen_string_literal: true

require 'java'

# Alias for is_a? testing
java_import org.openhab.core.library.items.DimmerItem
Dimmer = DimmerItem

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::DimmerItem
  # rubocop:enable Style/ClassAndModuleChildren
  java_import org.openhab.core.library.types.DecimalType
  java_import org.openhab.core.library.types.IncreaseDecreaseType
  #  include ItemCheck

  def +(other)
    return unless state?

    state.to_big_decimal.intValue + other
  end

  def -(other)
    return unless state?

    state.to_big_decimal.intValue - other
  end

  def dim(amount = 1)
    return unless state?

    target = [state.to_big_decimal.intValue - amount, 0].max

    if amount == 1
      command(IncreaseDecreaseType::DECREASE)
    else
      command(target)
    end

    target
  end

  def brighten(amount = 1)
    return unless state?

    target = state.to_big_decimal.intValue + amount

    if amount == 1
      command(IncreaseDecreaseType::INCREASE)
    else
      command(target)
    end
    target
  end

  def truthy?
    state? && state != DecimalType::ZERO
  end

  def to_i
    state&.to_big_decimal&.intValue
  end

  alias to_int to_i

  def on?
    state&.to_big_decimal&.intValue&.positive?
  end

  def off?
    state&.to_big_decimal&.intValue&.zero?
  end
end
