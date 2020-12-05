# frozen_string_literal: true

require 'java'

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryTypes::OnOffType
  # rubocop:enable Style/ClassAndModuleChildren

  def ===(other)
    # rubocop:disable Style/CaseLikeIf
    if self == ON
      return nil unless other.respond_to?('on?')

      other.on?
    elsif self == OFF
      return nil unless other.respond_to?('off?')

      other.off?
    else
      false
    end
    # rubocop:enable Style/CaseLikeIf
  end
end
