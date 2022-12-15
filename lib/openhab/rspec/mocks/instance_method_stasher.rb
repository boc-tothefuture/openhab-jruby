# frozen_string_literal: true

module OpenHAB
  module RSpec
    module Mocks
      module InstanceMethodStasher
        ::RSpec::Mocks::InstanceMethodStasher.prepend(self)

        # Disable "singleton on non-persistent Java type"
        # it doesn't matter during specs
        def initialize(*)
          original_verbose = $VERBOSE
          $VERBOSE = nil

          super
        ensure
          $VERBOSE = original_verbose
        end
      end
    end
  end
end
