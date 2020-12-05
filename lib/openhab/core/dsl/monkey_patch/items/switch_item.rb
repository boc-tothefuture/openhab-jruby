# frozen_string_literal: true

java_import org.openhab.core.library.items.SwitchItem

# Alias class names for easy is_a? comparisons
Switch = SwitchItem

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::SwitchItem
  java_import org.openhab.core.library.types.OnOffType
  # rubocop:enable Style/ClassAndModuleChildren

  def active?
    on?
  end

  def off
    command(OnOffType::OFF)
  end

  def on
    command(OnOffType::ON)
  end

  def on?
    item_defined? && state == OnOffType::ON
  end

  def off?
    item_defined? && state == OnOffType::OFF
  end

  def ==(other)
    if other.is_a? OnOffType
      item_defined? && state == other
    else
      super
    end
  end
end

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::NumberItem
  # rubocop:enable Style/ClassAndModuleChildren
  java_import org.openhab.core.library.types.DecimalType

  def active?
    item_defined? && state != DecimalType::ZERO
  end
end
