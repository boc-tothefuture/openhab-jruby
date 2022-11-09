# frozen_string_literal: true

require "forwardable"

module OpenHAB
  module Core
    #
    # Timer allows you to administer the block of code that
    # has been scheduled to run later with {DSL#after after}.
    #
    # @!attribute [r] execution_time
    #   @return [java.time.ZonedDateTime] The scheduled execution time, or null if the timer was cancelled
    class Timer
      extend Forwardable

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
      def_delegators :@timer, :execution_time, :active?, :cancelled?, :running?

      class << self
        # Create or reschedule a reentrant time
        #
        # @param [java.time.temporal.TemporalAmount, #to_zoned_date_time, Proc] time when to execute the block
        # @param [Object] id to associate with timer
        # @param [Block] block to execute, block is passed a Timer object
        # @return [ReentrantTimer] Timer object
        def reentrant_timer(time, id:, thread_locals: nil, &block)
          timer = DSL::TimerManager.instance.reentrant_timer(id: id, &block)
          if timer
            logger.trace("Reentrant timer found - #{timer}")
            timer.cancel
          else
            logger.trace("No reentrant timer found, creating new timer")
          end
          ReentrantTimer.new(time, id: id, thread_locals: thread_locals, &block)
        end
      end

      #
      # Create a new Timer Object
      #
      # @param [java.time.temporal.TemporalAmount, #to_zoned_date_time, Proc] time When to execute the block
      # @yield Block to execute when timer fires
      # @yieldparam [Timer] timer
      #
      def initialize(time, thread_locals: {}, &block)
        @time = time
        @block = block
        @timer = org.openhab.core.model.script.actions.ScriptExecution.create_timer(
          # create it far enough in the future so it won't execute until we finish setting it up
          1.minute.from_now,
          # when running in rspec, it may have troubles finding this class
          # for auto-conversion of block to interface, so use .impl
          org.eclipse.xtext.xbase.lib.Procedures::Procedure0.impl do
            DSL::TimerManager.instance.delete(self)
            DSL::ThreadLocal.thread_local(**thread_locals) do
              yield(self)
            end
          end
        )
        DSL::TimerManager.instance.add(self)
        @timer.reschedule(new_execution_time(@time))
      end

      # @return [String]
      def inspect
        r = "#<#{self.class.name} #{id}"
        if cancelled?
          r += " (canceled)"
        else
          r += " @ #{execution_time}"
          r += " (executed)" if terminated?
        end
        "#{r}>"
      end
      alias_method :to_s, :inspect

      #
      # Reschedule timer
      #
      # @param [java.time.temporal.TemporalAmount, ZonedDateTime, Proc, nil] time When to reschedule the timer for.
      #   If unspecified, the original time is used.
      #
      # @return [self]
      #
      def reschedule(time = nil)
        DSL::TimerManager.instance.add(self)
        @timer.reschedule(new_execution_time(time || @time))
        self
      end

      #
      # Cancel timer
      #
      # @return [true,false] True if cancel was successful, false otherwise
      #
      def cancel
        DSL::TimerManager.instance.delete(self)
        @timer.cancel
      end

      protected

      # Timer ID
      # @return [String]
      def id
        @block.source_location.join(":")
      end

      #
      # @return [java.time.ZonedDateTime]
      #
      def new_execution_time(time)
        time = time.call if time.is_a?(Proc)
        time = time.from_now if time.is_a?(java.time.temporal.TemporalAmount)
        time.to_zoned_date_time
      end
    end
  end
end
