# frozen_string_literal: true

require "set"
require "singleton"

module OpenHAB
  module DSL
    #
    # Manages data structures that track timers
    #
    # @!visibility private
    class TimerManager
      include Singleton

      ScriptHandling.script_unloaded { instance.cancel_all }

      attr_reader :timers_by_id

      def initialize
        # Track timer IDs
        @timers_by_id = {}

        @reentrant_timers = Hash.new { |h, k| h[k] = {} }

        # Tracks active timers
        @timers = Set.new
      end

      #
      # Adds the current timer to the set of rule timers if being tracked
      #
      def create(duration, thread_locals:, block:, id: nil)
        @reentrant_timers[id][block.source_location]&.cancel if id

        Core::Timer.new(duration, id: id, thread_locals: thread_locals, block: block) do |timer|
          add(timer)
        end
      end

      # Add a timer that is now active
      def add(timer)
        logger.trace("Adding #{timer} to timers")
        @timers << timer

        return unless timer.id

        logger.trace("Adding #{timer} with id #{timer.id.inspect} to timer ids")
        timers_by_id[timer.id] ||= TimerSet.new
        timers_by_id[timer.id] << timer
        @reentrant_timers[timer.id][timer.block.source_location] = timer
      end

      #
      # Delete a timer that is no longer active
      #
      def delete(timer)
        logger.trace("Removing #{timer} from timers")
        @timers.delete(timer)
        return unless timer.id

        if (timer_set = timers_by_id[timer.id])
          timer_set.delete(timer)
          timers_by_id.delete(timer.id) if timer_set.empty?
        end
        timer_hash = @reentrant_timers[timer.id]
        timer_hash.delete(timer.block.source_location)
        @reentrant_timers.delete(timer.id) if timer_hash.empty?
      end

      #
      # Cancels all active timers
      #
      def cancel_all
        logger.trace("Canceling #{@timers.length} timers")
        @timers.each(&:cancel)
      end

      #
      # Counts how many timers are active
      #
      def active_timer_count
        @timers.count(&:active?)
      end
    end

    #
    # Provide additional methods for the timers set
    #
    class TimerSet < Set
      #
      # A shorthand to cancel all the timer objects held within the set
      # so that timers[timer_id].cancel is equivalent to timers[timer_id].each(&:cancel)
      #
      def cancel
        each(&:cancel)
      end

      #
      # A shorthand to reschedule all the timer objects held within the set
      #
      # @param [Duration, #to_zoned_date_time, Proc, nil] time An optional time to reschedule
      #
      # @return [TimerSet] Set of timers
      #
      def reschedule(time = nil)
        each { |timer| timer.reschedule(time) }
      end
    end
  end
end
