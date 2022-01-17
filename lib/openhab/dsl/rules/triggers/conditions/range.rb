# frozen_string_literal: true

require 'openhab/log/logger'

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
          # This creates trigger conditions that work on ranges
          # @param [Range:] From range
          # @param [To:] To range
          #
          class Range
            def initialize(from: nil, to: nil)
              @from = from
              @to = to
            end

            #
            # Process rule
            # @param [Hash] inputs inputs from trigger
            #
            def process(mod:, inputs:) # rubocop:disable Lint/UnusedMethodArgument - mod is unused here but required
              logger.trace("Checking #{inputs} against condition trigger #{self}")
              yield if check_from(inputs: inputs) && check_to(inputs: inputs)
            end

            #
            # Check if from condition match the inputs
            # @param [Hash] inputs inputs from trigger
            # @return [true/false] depending on if from is set and matches supplied conditions
            #
            def check_from(inputs:)
              old_state = inputs['oldState']
              return true if @from.nil? || @from.include?(old_state)

              logger.trace("Skipped execution of rule because old state #{old_state}"\
                           " does not equal specified range(#{@from})")
              false
            end

            #
            # Check if to conditions match the inputs
            # @param [Hash] inputs inputs from trigger
            # @return [true/false] depending on if from is set and matches supplied conditions
            #
            def check_to(inputs:)
              new_state = inputs['newState'] || inputs['state'] # Get state for changed or update
              return true if @to.nil? || @to.include?(new_state)

              logger.trace("Skipped execution of rule because new state #{new_state}"\
                           " does not equal specified range(#{@to})")
              false
            end

            # Describe the Range Condition as a string
            # @return [String] string representation of range condition
            #
            def to_s
              "From:(#{@from}) To:(#{@to})"
            end
          end
        end
      end
    end
  end
end
