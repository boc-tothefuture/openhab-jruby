# frozen_string_literal: true

require 'java'

# Alias for is_a? testing
java_import org.openhab.core.library.items.ContactItem
Contact = ContactItem

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryItems::ContactItem
  java_import org.openhab.core.library.types.OpenClosedType
  # rubocop:enable Style/ClassAndModuleChildren

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
end
