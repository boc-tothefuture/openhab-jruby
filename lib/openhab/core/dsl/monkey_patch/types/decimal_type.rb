# frozen_string_literal: true

require 'java'

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryTypes::DecimalType
  # rubocop:enable Style/ClassAndModuleChildren

  def ==(other)
    return equals(other) unless other.is_a? Integer

    to_big_decimal.compare_to(Java::JavaMath::BigDecimal.new(other)).zero?
  end
end
