# frozen_string_literal: true

require 'java'
require 'delegate'
require 'forwardable'

module OpenHAB
  module Core
    module DSL
      #
      # Provides access to and ruby wrappers around OpenHAB timers
      #
      module Timers
        java_import org.openhab.core.model.script.actions.ScriptExecution
        java_import java.time.ZonedDateTime

        # Ruby wrapper for OpenHAB Timer
        # This class implements delegator to delegate methods to the OpenHAB timer
        #
        # @author Brian O'Connell
        # @since 2.0.0
        class Timer < SimpleDelegator
          extend Forwardable

          def_delegator :@timer, :is_active, :active?
          def_delegator :@timer, :is_running, :running?
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

            block = synchronized_block(semaphore, block)

            semaphore.synchronize do
              @timer = ScriptExecution.createTimer(
                ZonedDateTime.now.plus(Java::JavaTime::Duration.ofMillis(@duration.to_ms)), block
              )
              super(@timer)
            end
          end

          #
          # Reschedule timer
          #
          # @param [Duration] duration
          #
          # @return [<Type>] <description>
          #
          def reschedule(duration = nil)
            duration ||= @duration
            @timer.reschedule(ZonedDateTime.now.plus(duration))
          end
        end

        #
        # Execute the supplied block after the specified duration
        #
        # @param [Duration] duration after which to execute the block
        # @param [Block] block to execute, block is passed a Timer object
        #
        # @return [Timer] Timer object
        #
        def after(duration, &block)
          Timer.new(duration: duration, &block)
        end

        private

        #
        # Wrap a supplied block in a proc and synchronize access to it
        #
        # @param [Mutex] semaphore for synchronization
        # @param [Proc] block to synchronize access against
        #
        # @return [Proc] Synchronized proc
        #
        def synchronized_block(semaphore, block)
          proc do
            semaphore.synchronize do
              block.call(self)
            end
          end
        end
      end
    end
  end
end
