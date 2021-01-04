# frozen_string_literal: true

java_import org.openhab.core.library.items.SwitchItem

# Alias class names for easy is_a? comparisons
Switch = SwitchItem

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::SwitchItem
  java_import org.openhab.core.library.types.OnOffType
  # rubocop:enable Style/ClassAndModuleChildren

  def truthy?
    on?
  end

  def off
    command(OnOffType::OFF)
  end

  def on
    command(OnOffType::ON)
  end

  def on?
    state? && state == OnOffType::ON
  end

  def off?
    state? && state == OnOffType::OFF
  end

  def !
    return !state if state?

    OnOffType::ON
  end

  def ==(other)
    if other.is_a? OnOffType
      state? && state == other
    else
      super
    end
  end
end
