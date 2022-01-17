# frozen_string_literal: true

require 'openhab/log/logger'
require 'singleton'

module OpenHAB
  module DSL
    module Rules
      module Triggers
        #
        # Module for conditions for triggers
        #
        module Conditions
          include OpenHAB::Log
          #
          # this is a no-op condition which simply executes the provided block
          #
          class None
            include Singleton

            # Process rule
            # @param [Hash] inputs inputs from trigger
            #
            def process(*)
              yield
            end
          end
        end
      end
    end
  end
end
