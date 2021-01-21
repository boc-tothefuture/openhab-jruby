# frozen_string_literal: true

java_import org.openhab.core.library.items.SwitchItem

# Alias class names for easy is_a? comparisons
Switch = SwitchItem

#
# Monkeypatching SwitchItem to add Ruby Support methods
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::SwitchItem
  java_import org.openhab.core.library.types.OnOffType
  # rubocop:enable Style/ClassAndModuleChildren

  #
  # Send the OFF command to the switch
  #
  #
  def off
    command(OnOffType::OFF)
  end

  #
  # Send the OFF command to the switch
  #
  #
  def on
    command(OnOffType::ON)
  end

  #
  # Check if a switch is on
  #
  # @return [Boolean] True if the switch is on, false otherwise
  #
  def on?
    state? && state == OnOffType::ON
  end

  alias truthy? on?

  #
  # Check if a switch is off
  #
  # @return [Boolean] True if the switch is off, false otherwise
  #
  def off?
    state? && state == OnOffType::OFF
  end

  #
  # Invert the state if the switch state is not UNDEF or NULL
  #
  # @return [OnOffType] Inverted state or nil
  #
  def !
    return !state if state?

    OnOffType::ON
  end

  #
  # Check for equality against supplied object
  #
  # @param [Object] other object to compare to
  #
  # @return [Boolean] True if other is a OnOffType and other equals state for this switch item, otherwise result from super
  #
  def ==(other)
    if other.is_a? OnOffType
      state? && state == other
    else
      super
    end
  end
end
