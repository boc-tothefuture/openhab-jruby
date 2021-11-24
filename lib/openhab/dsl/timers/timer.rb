# frozen_string_literal: true

require 'java'
require 'delegate'
require 'forwardable'
require 'openhab/log/logger'

module OpenHAB
  module DSL
    #
    # Provides access to and ruby wrappers around OpenHAB timers
    #
    module Timers
      include OpenHAB::Log
      java_import org.openhab.core.model.script.actions.ScriptExecution
      java_import java.time.ZonedDateTime

      # Ruby wrapper for OpenHAB Timer
      # This class implements delegator to delegate methods to the OpenHAB timer
      #
      # @author Brian O'Connell
      # @since 2.0.0
      class Timer < SimpleDelegator
        include OpenHAB::Log
        extend Forwardable

        def_delegator :@timer, :has_terminated, :terminated?

        #
        # Create a new Timer Object
        #
        # @param [Duration] duration Duration until timer should fire
        # @param [Block] block Block to execute when timer fires
        #
        def initialize(duration:, &block)
          @duration = duration

          # A semaphore is used to prevent a race condition in which calling the block from the timer thread
          # occurs before the @timer variable can be set resulting in @timer being nil
          semaphore = Mutex.new

          semaphore.synchronize do
            @timer = ScriptExecution.createTimer(
              ZonedDateTime.now.plus(@duration), timer_block(semaphore, &block)
            )
            super(@timer)
            Timers.timer_manager.add(self)
          end
        end

        #
        # Reschedule timer
        #
        # @param [Duration] duration
        #
        # @return [Timer] Rescheduled timer instances
        #
        def reschedule(duration = nil)
          unless duration.nil? || duration.is_a?(Java::JavaTimeTemporal::TemporalAmount)
            raise ArgumentError, 'Supplied argument must be a duration'
          end

          duration ||= @duration
          Timers.timer_manager.add(self)
          @timer.reschedule(ZonedDateTime.now.plus(duration))
        end

        # Cancel timer
        #
        # @return [Boolean] True if cancel was successful, false otherwise
        #
        def cancel
          Timers.timer_manager.delete(self)
          @timer.cancel
        end

        private

        #
        # Constructs a block to execute timer within
        #
        # @param [Semaphore] Semaphore to obtain before executing
        #
        # @return [Proc] Block for timer to execute
        #
        def timer_block(semaphore)
          proc {
            semaphore.synchronize do
              Timers.timer_manager.delete(self)
              yield(self)
            end
          }
        end
      end
    end
  end
end
