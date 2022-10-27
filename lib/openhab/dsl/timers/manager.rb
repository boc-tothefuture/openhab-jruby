# frozen_string_literal: true

require "set"
require "openhab/log/logger"
require_relative "reentrant_timer"

module OpenHAB
  module DSL
    #
    # Provides supporting classes for Timers module
    #
    module Support
      #
      # Manages data structures that track timers
      #
      class TimerManager
        include OpenHAB::Log

        attr_reader :timer_ids

        def initialize
          # Track timer IDs
          @timer_ids = {}

          # Reentrant timer lookups
          @reentrant_timers = {}

          # Tracks active timers
          @timers = Set.new
        end

        #
        # Adds the current timer to the set of rule timers if being tracked
        #
        # It does not make sense to break this up into seperate components
        def add(timer)
          logger.trace("Adding #{timer} to timers")
          @timers << timer

          if timer.respond_to? :id
            logger.trace("Adding #{timer} with id #{timer.id.inspect} timer ids")
            @timer_ids[timer.id] = TimerSet.new unless @timer_ids[timer.id]
            @timer_ids[timer.id] << timer
          end

          return unless timer.respond_to? :reentrant_id

          logger.trace("Adding reeentrant #{timer} with reentrant id #{timer.reentrant_id} timer ids")
          @reentrant_timers[timer.reentrant_id] = timer
        end

        # Fetches the reentrant timer that matches the supplied id and block if it exists
        #
        # @param [Object] id Object to associate with timer
        # @param [Block] block to execute, block is passed a Timer object
        #
        # @return [RentrantTimer] Timer object if it exists, nil otherwise
        #
        def reentrant_timer(id:, &block)
          reentrant_key = ReentrantTimer.reentrant_id(id: id, &block)
          logger.trace("Checking for existing reentrant timer for #{reentrant_key}")
          @reentrant_timers[reentrant_key]
        end

        #
        # Delete the current timer to the set of rule timers if being tracked
        #
        def delete(timer)
          logger.trace("Removing #{timer} from timers")
          @timers.delete(timer)
          if timer.respond_to?(:id) && (timers = @timer_ids[timer.id])
            timers.delete(timer)
            @timer_ids.delete(timer.id) if timers.empty?
          end
          @reentrant_timers.delete(timer.reentrant_id) if timer.respond_to? :reentrant_id
        end

        #
        # Cancels all active timers
        #
        def cancel_all
          logger.trace("Canceling #{@timers.length} timers")
          @timers.each(&:cancel)
          @timer_ids.clear
          @reentrant_timers.clear
          @timers.clear
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
        # @deprecated Please use {cancel} instead
        alias_method :cancel_all, :cancel

        #
        # A shorthand to reschedule all the timer objects held within the set
        #
        # @param [Duration] duration An optional duration to reschedule
        #
        # @return [TimerSet] Set of timers
        #
        def reschedule(duration = nil)
          each { |timer| timer.reschedule duration }
        end
      end
    end
  end
end
