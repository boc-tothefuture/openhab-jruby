# frozen_string_literal: true

require_relative "type"

module OpenHAB
  module Core
    module Types
      UnDefType = org.openhab.core.types.UnDefType

      # There are situations when item states do not have any defined value.
      # This might be because they have not been initialized yet (never
      # received an state update so far) or because their state is ambiguous
      # (e.g. a group item with members whose states do not match will be
      # {NULL}).
      class UnDefType # rubocop:disable Lint/EmptyClass
        # @!parse include State

        # @!constant NULL
        #   Null State
        # @!constant UNDEF
        #   Undef State

        # @!method null?
        #   Check if `self` == {NULL}
        #   @return [true,false]

        # @!method undef?
        #   Check if `self` == {UNDEF}
        #   @return [true,false]
      end
    end
  end
end

# @!parse
#   UnDefType = OpenHAB::Core::Types::UnDefType
#   NULL = OpenHAB::Core::Types::UnDefType::NULL
#   UNDEF = OpenHAB::Core::Types::UnDefType::UNDEF
