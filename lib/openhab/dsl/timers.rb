# frozen_string_literal: true

require_relative 'timers/timer'
require_relative 'timers/manager'
require_relative 'timers/reentrant_timer'

module OpenHAB
  module DSL
    #
    # Provides access to and ruby wrappers around OpenHAB timers
    #
    module Timers
      include OpenHAB::Log

      # Manages timers
      @timer_manager = TimerManager.new

      class << self
        attr_reader :timer_manager
      end

      #
      # Execute the supplied block after the specified duration
      #
      # @param [Duration] duration after which to execute the block
      # @param [Object] id to associate with timer
      # @param [Block] block to execute, block is passed a Timer object
      #
      # @return [Timer] Timer object
      #
      def after(duration, id: nil, &block)
        return Timers.reentrant_timer(duration: duration, id: id, &block) if id

        Timer.new(duration: duration, &block)
      end

      #
      # Provdes access to the hash for mapping timer ids to the set of active timers associated with that id
      # @return [Hash] hash of user specified ids to sets of times
      def timers
        Timers.timer_manager.timer_ids
      end

      #
      # Cancels all active timers
      #
      def self.cancel_all
        @timer_manager.cancel_all
      end

      # Create or reschedule a reentrant time
      #
      # @param [Duration] duration after which to execute the block
      # @param [Object] id to associate with timer
      # @param [Block] block to execute, block is passed a Timer object
      # @return [ReentrantTimer] Timer object
      def self.reentrant_timer(duration:, id:, &block)
        timer = @timer_manager.reentrant_timer(id: id, &block)
        if timer
          logger.trace("Reentrant timer found - #{timer}")
          timer.cancel
        else
          logger.trace('No reentrant timer found, creating new timer')
        end
        ReentrantTimer.new(duration: duration, id: id, &block)
      end
    end
  end
end
