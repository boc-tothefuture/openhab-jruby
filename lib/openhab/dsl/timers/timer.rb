# frozen_string_literal: true

require "java"
require "delegate"
require "forwardable"
require "openhab/log/logger"
require "openhab/core/thread_local"

module OpenHAB
  module DSL
    java_import org.openhab.core.model.script.actions.ScriptExecution

    # Ruby wrapper for OpenHAB Timer
    # This class implements delegator to delegate methods to the OpenHAB timer
    #
    # @author Brian O'Connell
    # @since 2.0.0
    class Timer < SimpleDelegator
      include OpenHAB::Log
      include OpenHAB::Core::ThreadLocal
      extend Forwardable

      def_delegator :@timer, :has_terminated, :terminated?

      #
      # Create a new Timer Object
      #
      # @param [Duration] duration Duration until timer should fire
      # @param [Block] block Block to execute when timer fires
      #
      def initialize(duration:, thread_locals: {}, &block)
        @duration = duration
        @thread_locals = thread_locals

        # A semaphore is used to prevent a race condition in which calling the block from the timer thread
        # occurs before the @timer variable can be set resulting in @timer being nil
        semaphore = Mutex.new

        semaphore.synchronize do
          @timer = ScriptExecution.createTimer(OpenHAB::DSL.to_zdt(@duration), timer_block(semaphore, &block))
          @rule_timers = Thread.current[:rule_timers]
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
        duration ||= @duration

        Timers.timer_manager.add(self)
        @timer.reschedule(OpenHAB::DSL.to_zdt(duration))
      end

      #
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
      # @param [Semaphore] semaphore to obtain before executing
      #
      # @return [Proc] Block for timer to execute
      #
      def timer_block(semaphore)
        proc {
          OpenHAB::DSL.import_presets
          semaphore.synchronize do
            Timers.timer_manager.delete(self)
            thread_local(**@thread_locals) do
              yield(self)
            end
          end
        }
      end
    end

    #
    # Convert TemporalAmount (Duration), seconds (float, integer), and Ruby Time to ZonedDateTime
    # Note: TemporalAmount is added to now
    #
    # @param [Object] timestamp to convert
    #
    # @return [ZonedDateTime]
    #
    def self.to_zdt(timestamp)
      logger.trace("Converting #{timestamp} (#{timestamp.class}) to ZonedDateTime")
      return unless timestamp

      case timestamp
      when java.time.temporal.TemporalAmount then ZonedDateTime.now.plus(timestamp)
      when ZonedDateTime then timestamp
      when Time then timestamp.to_java(ZonedDateTime)
      else
        to_zdt(seconds_to_duration(timestamp)) ||
          raise(ArgumentError, "Timestamp must be a ZonedDateTime, a Duration, a Numeric, or a Time object")
      end
    end

    #
    # Convert numeric seconds to a Duration object
    #
    # @param [Float, Integer] secs The number of seconds in integer or float
    #
    # @return [Duration]
    #
    def self.seconds_to_duration(secs)
      return unless secs

      if secs.respond_to?(:to_f)
        secs.to_f.seconds
      elsif secs.respond_to?(:to_i)
        secs.to_i.seconds
      end
    end
  end
end
