# frozen_string_literal: true

require 'java'

#
# MonkeyPatching Decimal Type
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryTypes::DecimalType
  # rubocop:enable Style/ClassAndModuleChildren

  #
  # Compare self to other using Java BigDecimal compare method
  #
  # @param [Object] other object to compare to
  #
  # @return [Boolean] True if have the same BigDecimal representation, false otherwise
  #
  def ==(other)
    return equals(other) unless other.is_a? Integer

    to_big_decimal.compare_to(Java::JavaMath::BigDecimal.new(other)).zero?
  end
end
