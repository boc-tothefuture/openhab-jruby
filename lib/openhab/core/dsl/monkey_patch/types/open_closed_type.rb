# frozen_string_literal: true

require 'java'


#
# Monkey patch for DSL use
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryTypes::OpenClosedType
  # rubocop:enable Style/ClassAndModuleChildren
  java_import org.openhab.core.library.items.ContactItem

  #
  # Check if the supplied object is case equals to self
  #
  # @param [Object] other object to compare
  #
  # @return [Boolean] True if the other object is a ContactItem and has the same state
  #
  def ===(other)
    super unless other.is_a? ContactItem

    self == other.state
  end
end
