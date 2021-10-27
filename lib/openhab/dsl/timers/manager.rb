# frozen_string_literal: true

require 'openhab/log/logger'
require_relative 'reentrant_timer'

module OpenHAB
  module DSL
    #
    # Provides access to and ruby wrappers around OpenHAB timers
    #
    module Timers
      #
      # Manages data structures that track timers
      #
      class TimerManager
        include OpenHAB::Log

        attr_reader :timer_ids

        def initialize
          # Track timer IDs
          @timer_ids = Hash.new { |hash, key| hash[key] = Set.new }

          # Reentrant timer lookups
          @reentrant_timers = {}

          # Tracks active timers
          @timers = Set.new
        end

        #
        # Adds the current timer to the set of rule timers if being tracked
        #
        # rubocop: disable Metrics/AbcSize
        # It does not make sense to break this up into seperate components
        def add(timer)
          logger.trace("Adding #{timer} to timers")
          @timers << timer

          if timer.respond_to? :id
            logger.trace("Adding #{timer} with id #{timer.id.inspect} timer ids")
            @timer_ids[timer.id] << timer
          end

          return unless timer.respond_to? :reentrant_id

          logger.trace("Adding reeentrant #{timer} with reentrant id #{timer.reentrant_id} timer ids")
          @reentrant_timers[timer.reentrant_id] = timer
        end
        # rubocop: enable Metrics/AbcSize

        # Fetches the reentrant timer that matches the supplied id and block if it exists
        #
        # @param [Object] Object to associate with timer
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
          @timer_ids[timer.id].delete(timer) if (timer.respond_to? :id) && (@timer_ids.key? timer.id)
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
      end
    end
  end
end
