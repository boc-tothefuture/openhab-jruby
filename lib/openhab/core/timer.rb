# frozen_string_literal: true

require "forwardable"

module OpenHAB
  module Core
    #
    # Timer allows you to administer the block of code that
    # has been scheduled to run later with {OpenHAB::DSL.after after}.
    #
    # @!attribute [r] execution_time
    #   @return [ZonedDateTime] the scheduled execution time, or null if the timer was cancelled
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

      # @return [Object, nil]
      attr_accessor :id

      # @!visibility private
      # @!visibility private
      attr_reader :block

      #
      # Create a new Timer Object
      #
      # @param [java.time.temporal.TemporalAmount, #to_zoned_date_time, Proc] time When to execute the block
      # @yield Block to execute when timer fires
      # @yieldparam [self]
      #
      # @!visibility private
      def initialize(time, id:, thread_locals:, block:)
        @time = time
        @id = id
        @thread_locals = thread_locals
        @block = block
        @timer = org.openhab.core.model.script.actions.ScriptExecution.create_timer(
          # create it far enough in the future so it won't execute until we finish setting it up
          1.minute.from_now,
          # when running in rspec, it may have troubles finding this class
          # for auto-conversion of block to interface, so use .impl
          org.eclipse.xtext.xbase.lib.Procedures::Procedure0.impl { execute }
        )
        reschedule(@time)
      end

      # @return [String]
      def inspect
        r = "#<#{self.class.name} #{"#{id.inspect} " if id}#{block.source_location.join(":")}"
        if cancelled?
          r += " (cancelled)"
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
        DSL.timers.add(self)
        @timer.reschedule(new_execution_time(time || @time))
        self
      end

      #
      # Cancel timer
      #
      # @return [true,false] True if cancel was successful, false otherwise
      #
      def cancel
        DSL.timers.delete(self)
        cancel!
      end

      #
      # Cancel the timer but do not remove self from the timer manager
      #
      # To be used internally by {TimerManager} from inside ConcurrentHashMap's compute blocks
      #
      # @return [true,false] True if cancel was successful, false otherwise
      #
      # @!visibility private
      def cancel!
        @timer.cancel
      end

      private

      #
      # Calls the block with thread locals set up, and cleans up after itself
      #
      # @return [void]
      #
      def execute
        last_execution_time = execution_time
        DSL::ThreadLocal.thread_local(**@thread_locals) do
          @block.call(self)
        end
        # don't remove ourselves if we were rescheduled in the block
        DSL.timers.delete(self) if execution_time == last_execution_time
      end

      #
      # @return [ZonedDateTime]
      #
      def new_execution_time(time)
        time = time.call if time.is_a?(Proc)
        time = time.from_now if time.is_a?(java.time.temporal.TemporalAmount)
        time.to_zoned_date_time
      end
    end
  end
end
