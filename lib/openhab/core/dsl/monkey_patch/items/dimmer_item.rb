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
    brighten(other)
    self
  end

  def -(other)
    dim(other)
    self
  end

  def dim(amount = 1)
    return unless item_defined?

    target = [state.to_big_decimal.intValue - amount, 0].max

    if amount == 1
      command(IncreaseDecreaseType::DECREASE)
    else
      command(target)
    end

    target
  end

  def brighten(amount = 1)
    return unless item_defined?

    target = state.to_big_decimal.intValue + amount

    if amount == 1
      command(IncreaseDecreaseType::INCREASE)
    else
      command(target)
    end
    target
  end

  def active?
    item_defined? && state != DecimalType::ZERO
  end

  def to_int
    state
  end

  def to_i
    state
  end

  def on?
    item_defined? && state.to_big_decimal.intValue.positive?
  end

  def off?
    item_defined? && state.to_big_decimal.intValue.zero?
  end
end
