# frozen_string_literal: true

require 'java'

#
# Monkey patching OnOffType
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryTypes::OnOffType
  # rubocop:enable Style/ClassAndModuleChildren

  #
  # Invert the type
  #
  # @return [Java::OrgOpenhabCoreLibraryTypes::OnOffType] OFF if ON, ON if OFF
  #
  def !
    return OFF if self == ON
    return ON if self == OFF
  end

  # Check if the supplied object is case equals to self
  #
  # @param [Object] other object to compare
  #
  # @return [Boolean] True if the other object responds to on?/off? and is in the same state as this object,
  #  nil if object cannot be compared
  #
  def ===(other)
    case self
    when ON
      return nil unless other.respond_to?('on?')

      other.on?
    when OFF
      return nil unless other.respond_to?('off?')

      other.off?
    else
      false
    end
  end
end
