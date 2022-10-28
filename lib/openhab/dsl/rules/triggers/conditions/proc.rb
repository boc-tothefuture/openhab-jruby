# frozen_string_literal: true

module OpenHAB
  module DSL
    module Rules
      module Triggers
        # @!visibility private
        module Conditions
          #
          # This creates trigger conditions that work on procs
          # @param [Proc] from Proc
          # @param [Proc] to Proc
          #
          class Proc
            #
            # Converts supplied ranges to procs that check range
            # @param [Array] ranges objects to convert to range proc if they are ranges
            # @return [Array] of procs or supplied arguments if argument was not of type Range
            #
            def self.range_procs(*ranges)
              ranges.map { |range| range.is_a?(Range) ? range_proc(range) : range }
            end

            #
            # Create a range proc for the supplied range object
            # @param [Range] range to build proc for
            #
            def self.range_proc(range)
              logger.trace("Creating range proc for #{range}")
              lambda do |val|
                logger.trace("Range proc checking if #{val} is in #{range}")
                range.cover? val
              end
            end

            #
            # Create an equality proc for the supplied range object
            # @param [State] value to build proc for
            #
            def self.equality_proc(value)
              logger.trace("Creating equality proc for #{value}")
              lambda do |state|
                logger.trace("Equality proc comparing #{value} against #{state}")
                value == state
              end
            end

            #
            # Constructs a proc for the specific value type
            #  if the value is a proc return the proc
            #  if the value is a range create a range proc
            #  if the value is nil, return nil
            #  otherwise create an equality proc
            # @param [Object] value to construct proc from
            def self.from_value(value)
              logger.trace("Creating proc for Value(#{value})")
              return value if value.nil?
              return value if value.is_a?(::Proc)
              return range_proc(value) if value.is_a?(Range)

              equality_proc(value)
            end

            #
            # Create a new Proc Condition that executes only if procs return true
            # @param [Proc] from Proc to check against from value
            # @param [Proc] to Proc to check against to value
            #
            def initialize(from: nil, to: nil, command: nil)
              @from = from
              @to = to
              @command = command
            end

            # Proc that doesn't check any fields
            ANY = Proc.new.freeze # this needs to be defined _after_ initialize so its instance variables are set

            #
            # Process rule
            # @param [Hash] inputs inputs from trigger
            #
            def process(mod:, inputs:) # rubocop:disable Lint/UnusedMethodArgument - mod is unused here but required
              logger.trace("Checking #{inputs} against condition trigger #{self}")
              yield if check_procs(inputs: inputs)
            end

            # Cleanup any resources from the condition
            def cleanup; end

            #
            # Check if command condition match the proc
            # @param [Hash] inputs from trigger must be supplied if state is not supplied
            # @return [true/false] depending on if from is set and matches supplied conditions
            #
            def check_command(inputs: nil)
              command = input_state(inputs, "command")
              logger.trace "Checking command(#{@command}) against command(#{command})"
              check_proc(proc: @command, value: command)
            end

            #
            # Check if from condition match the proc
            # @param [Hash] inputs from trigger must be supplied if state is not supplied
            # @param [String] state if supplied proc will be passed state value for comparision
            # @return [true/false] depending on if from is set and matches supplied conditions
            #
            def check_from(inputs: nil, state: nil)
              state ||= input_state(inputs, "oldState")
              logger.trace "Checking from(#{@from}) against state(#{state})"
              check_proc(proc: @from, value: state)
            end

            #
            # Check if to conditions match the proc
            # @param [Hash] inputs from trigger must be supplied if state is not supplied
            # @param [String] state if supplied proc will be passed state value for comparision
            # @return [true/false] depending on if from is set and matches supplied conditions
            #
            def check_to(inputs: nil, state: nil)
              state ||= input_state(inputs, "newState", "state")
              logger.trace "Checking to(#{@to}) against state(#{state})"
              check_proc(proc: @to, value: state)
            end

            # Describe the Proc Condition as a string
            # @return [String] string representation of proc condition
            #
            def to_s
              "From:(#{@from}) To:(#{@to}) Command:(#{@command})"
            end

            private

            #
            # Check all procs
            # @param [Hash] inputs from event
            # @return [true/false] true if all procs return true, false otherwise
            def check_procs(inputs:)
              check_from(inputs: inputs) && check_to(inputs: inputs) && check_command(inputs: inputs)
            end

            # Check if a field matches the proc condition
            # @param [Proc] proc to call
            # @param [Hash] value to check
            # @return [true,false] true if proc is nil or proc.call returns true, false otherwise
            def check_proc(proc:, value:)
              return true if proc.nil? || proc.call(value)

              logger.trace("Skipped execution of rule because value #{value} evaluated false for (#{proc})")
              false
            end

            # Get the first field from supplied fields in inputs
            # @param [Hash] inputs containing fields
            # @param [Array] fields array of fields to extract from inputs, first one found is returned
            def input_state(inputs, *fields)
              fields.map { |f| inputs[f] }.compact.first
            end
          end
        end
      end
    end
  end
end
