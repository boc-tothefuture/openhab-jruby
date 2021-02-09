# frozen_string_literal: true

require 'java'

#
# MonkeyPatching QuantityType
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryTypes::QuantityType
  # rubocop:enable Style/ClassAndModuleChildren

  #
  # Compare QuantityType to supplied object
  #
  # @param [Object] other object to compare to
  #
  # @return [Integer] -1,0,1 or nil depending on value supplied, nil comparison to supplied object is not possible.
  #
  def <=>(other)
    logger.trace("#{self.class} #{self} <=> #{other} (#{other.class})")
    case other
    when Java::OrgOpenhabCoreTypes::UnDefType then 1
    when String then self <=> Quantity.new(other)
    when OpenHAB::Core::DSL::Types::Quantity then self <=> other.quantity
    else
      other = other.state if other.respond_to? :state
      compare_to(other)
    end
  end

  #
  # Coerce objects into a QuantityType
  #
  # @param [Object] other object to coerce to a QuantityType if possible
  #
  # @return [Object] Numeric when applicable
  #
  def coerce(other)
    logger.trace("Coercing #{self} as a request from #{other.class}")
    case other
    when String
      [Quantity.new(other), self]
    else
      [other, self]
    end
  end

  #
  # Compare self to other using the spaceship operator
  #
  # @param [Object] other object to compare to
  #
  # @return [Boolean] True if equals
  #
  def ==(other)
    (self <=> other).zero?
  end
end
