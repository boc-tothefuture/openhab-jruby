# frozen_string_literal: true

require 'java'

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryTypes::OpenClosedType
  # rubocop:enable Style/ClassAndModuleChildren
  java_import org.openhab.core.library.items.ContactItem

  def ===(other)
    super unless other.is_a? ContactItem

    self == other.state
  end
end
