# frozen_string_literal: true

require 'java'
require 'core/log'

java_import org.openhab.core.library.items.SwitchItem
java_import org.openhab.core.library.items.DimmerItem
java_import org.openhab.core.library.items.StringItem
java_import org.openhab.core.library.items.ContactItem
java_import org.openhab.core.library.items.NumberItem

# Alias class names for easy is_a? comparisons
# Doesn't work for String or Number...
Switch = SwitchItem
Dimmer = DimmerItem

module Bus
  include Logging
  java_import org.openhab.core.model.script.actions.BusEvent

  def command(command)
    logger.trace "Sending Command #{command} to #{self}"
    BusEvent.sendCommand(self, command.to_s)
  end

  def state=(command)
    command(command)
  end

  alias << state=
end

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreItems::GenericItem
  java_import org.openhab.core.types.UnDefType
  # rubocop:enable Style/ClassAndModuleChildren
  def item_defined?
    logger.trace "Checking #{self} State: #{state}"
    state != UnDefType::UNDEF && state != UnDefType::NULL
  end
end

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::StringItem
  # rubocop:enable Style/ClassAndModuleChildren
  #  include ItemCheck
  include Bus

  def active?
    item_defined? && state&.empty?
  end
end

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::ContactItem
  java_import org.openhab.core.library.types.OpenClosedType
  # rubocop:enable Style/ClassAndModuleChildren
  #  include ItemCheck
  include Bus

  def open?
    item_defined? && state == OpenClosedType::OPEN
  end

  def closed?
    item_defined? && state == OpenClosedType::CLOSED
  end

  def ==(other)
    if other.is_a? OpenClosedType
      item_defined? && state == other
    else
      super
    end
  end

  def to_s
    label
  end

  def ===(_obj)
    puts 'Called here'
  end
end

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::SwitchItem
  java_import org.openhab.core.library.types.OnOffType
  # rubocop:enable Style/ClassAndModuleChildren
  #  include ItemCheck
  include Bus

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
class Java::OrgOpenhabCoreLibraryItems::DimmerItem
  # rubocop:enable Style/ClassAndModuleChildren
  java_import org.openhab.core.library.types.DecimalType
  java_import org.openhab.core.library.types.IncreaseDecreaseType
  #  include ItemCheck
  include Bus

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
end

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::NumberItem
  # rubocop:enable Style/ClassAndModuleChildren
  java_import org.openhab.core.library.types.DecimalType
  #  include ItemCheck
  include Bus

  def active?
    item_defined? && state != DecimalType::ZERO
  end
end

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreItems::GroupItem
  # rubocop:enable Style/ClassAndModuleChildren
  #  include ItemCheck
  include Bus

  def items
    to_a
  end

  def to_a
    all_members.each_with_object([]) { |item, arr| arr << item }
  end
end
