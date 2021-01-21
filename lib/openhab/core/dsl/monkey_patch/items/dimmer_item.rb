# frozen_string_literal: true

require 'java'

# Alias for is_a? testing
java_import org.openhab.core.library.items.DimmerItem
Dimmer = DimmerItem

#
# Monkey Patch DimmerItem
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::DimmerItem
  # rubocop:enable Style/ClassAndModuleChildren
  java_import org.openhab.core.library.types.DecimalType
  java_import org.openhab.core.library.types.IncreaseDecreaseType

  #
  # Add the current dimmer value to the supplied object
  #
  # @param [Object] other object to add the dimmer value to
  #
  # @return [Integer] Current dimmer value plus value of supplied object
  #
  def +(other)
    return unless state?

    state.to_big_decimal.intValue + other
  end

  #
  # Subtract the supplied object from the current value of the dimmer
  #
  # @param [Object] other object to subtract from the dimmer value
  #
  # @return [Integer] Current dimmer value minus value of supplied object
  #
  def -(other)
    return unless state?

    state.to_big_decimal.intValue - other
  end

  #
  # Dim the dimmer
  #
  # @param [Integer] amount to dim by
  #
  # @return [Integer] level target for dimmer
  #
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

  #
  # Brighten the dimmer
  #
  # @param [Integer] amount to brighten by
  #
  # @return [Integer] level target for dimmer
  #
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

  #
  # Check if dimmer has a state and state is not zero
  #
  # @return [Boolean] True if dimmer is not NULL or UNDEF and value is not 0
  #
  def truthy?
    state? && state != DecimalType::ZERO
  end

  #
  # Value of dimmer
  #
  # @return [Integer] Value of dimmer or nil if state is UNDEF or NULL
  #
  def to_i
    state&.to_big_decimal&.intValue
  end

  alias to_int to_i

  #
  # Check if dimmer is on
  #
  # @return [Boolean] True if item is not UNDEF or NULL and has a value greater than 0
  #
  def on?
    state&.to_big_decimal&.intValue&.positive?
  end

  #
  # Check if dimmer is off
  #
  # @return [Boolean] True if item is not UNDEF or NULL and has a state of 0
  #
  def off?
    state&.to_big_decimal&.intValue&.zero?
  end
end
