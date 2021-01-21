# frozen_string_literal: true

require 'java'

#
# MonkeyPatching PercentType
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryTypes::PercentType
  # rubocop:enable Style/ClassAndModuleChildren

  #
  # Need to override and point to super because default JRuby implementation doesn't point to == of parent class
  #
  # @param [Object] other object to check equality for
  # @return [Boolean] True if other equals self, false otherwise
  #
  # rubocop:disable Lint/UselessMethodDefinition
  def ==(other)
    super
  end
  # rubocop:enable Lint/UselessMethodDefinition
end
