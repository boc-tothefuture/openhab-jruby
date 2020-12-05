# frozen_string_literal: true

require 'java'
require 'core/log'

java_import org.openhab.core.library.items.StringItem

java_import org.openhab.core.library.items.NumberItem

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::StringItem
  # rubocop:enable Style/ClassAndModuleChildren
  #  include ItemCheck

  def active?
    item_defined? && state&.empty?
  end
end

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::ContactItem
  java_import org.openhab.core.library.types.OpenClosedType
  # rubocop:enable Style/ClassAndModuleChildren
  #  include ItemCheck

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
class Java::OrgOpenhabCoreItems::GroupItem
  # rubocop:enable Style/ClassAndModuleChildren
  #  include ItemCheck

  def items
    to_a
  end

  def to_a
    all_members.each_with_object([]) { |item, arr| arr << item }
  end
end
