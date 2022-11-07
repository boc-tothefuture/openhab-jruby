# frozen_string_literal: true

require "delegate"
require "forwardable"

module OpenHAB
  module DSL
    # Ruby wrapper for OpenHAB Timer
    # This class implements delegator to delegate methods to the OpenHAB timer
    #
    # @author Brian O'Connell
    #
    # @see https://www.openhab.org/javadoc/latest/org/openhab/core/model/script/actions/timer
    #

    class Timer < SimpleDelegator
      extend Forwardable

      # @!method execution_time
      #   Return the scheduled execution time of this timer.
      #   @return [ZonedDateTime] The scheduled execution time, or null if the timer was cancelled

      # @!method active?
      #   Check if the timer will execute in the future.
      #   @return [true,false]

      # @!method cancelled?
      #   Check if the timer has been cancelled.
      #   @return [true,false]

      # @!method running?
      #   Check if the timer code is currently running.
      #   @return [true,false]

      # @!method terminated?
      #   Check if the timer has terminated.
      #   @return [true,false]

      def_delegator :@timer, :has_terminated, :terminated?

      class << self
        # Create or reschedule a reentrant time
        #
        # @param [java.time.Duration] duration after which to execute the block
        # @param [Object] id to associate with timer
        # @param [Block] block to execute, block is passed a Timer object
        # @return [ReentrantTimer] Timer object
        def reentrant_timer(duration:, id:, thread_locals: nil, &block)
          timer = Manager.instance.reentrant_timer(id: id, &block)
          if timer
            logger.trace("Reentrant timer found - #{timer}")
            timer.cancel
          else
            logger.trace("No reentrant timer found, creating new timer")
          end
          ReentrantTimer.new(duration: duration, id: id, thread_locals: thread_locals, &block)
        end
      end

      #
      # Create a new Timer Object
      #
      # @param [java.time.Duration, ZonedDateTime, Time, Float, Integer, Proc] duration
      #   Duration or the number of seconds until the timer should fire,
      #   an absolute date+time when the timer should execute or a Proc that returns a Duration).
      # @param [Block] block Block to execute when timer fires
      #
      def initialize(duration:, thread_locals: {}, &block)
        @duration = duration
        @thread_locals = thread_locals

        # A semaphore is used to prevent a race condition in which calling the block from the timer thread
        # occurs before the @timer variable can be set resulting in @timer being nil
        semaphore = Mutex.new

        semaphore.synchronize do
          @timer = org.openhab.core.model.script.actions.ScriptExecution.createTimer(OpenHAB::DSL.to_zdt(@duration),
                                                                                     timer_block(semaphore, &block))
          @rule_timers = Thread.current[:rule_timers]
          super(@timer)
          Manager.instance.add(self)
        end
      end

      #
      # Reschedule timer
      #
      # @param [java.time.Duration, ZonedDateTime, nil] duration Duration or date+time to reschedule the timer.
      #   If unspecified, the original duration is used.
      #
      # @return [Timer] Rescheduled timer instances
      #
      def reschedule(duration = nil)
        duration ||= @duration

        Manager.instance.add(self)
        @timer.reschedule(OpenHAB::DSL.to_zdt(duration))
      end

      #
      # Cancel timer
      #
      # @return [true,false] True if cancel was successful, false otherwise
      #
      def cancel
        Manager.instance.delete(self)
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
          semaphore.synchronize do
            Manager.instance.delete(self)
            ThreadLocal.thread_local(**@thread_locals) do
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
    # @return [java.time.Duration]
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
