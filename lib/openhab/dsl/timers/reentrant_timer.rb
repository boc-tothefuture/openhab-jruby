# frozen_string_literal: true

require "openhab/log/logger"
require_relative "timer"

module OpenHAB
  module DSL
    # A reentrant timer is a timer that is automatically rescheduled
    # when the block it refers to is encountered again
    #
    # @author Brian O'Connell
    # @since 2.0.0
    class ReentrantTimer < Timer
      include OpenHAB::Log

      attr_reader :id, :reentrant_id

      #
      # Create a new Timer Object
      #
      # @param [Duration] duration Duration until timer should fire
      # @param [Block] block Block to execute when timer fires
      #
      def initialize(duration:, id:, thread_locals: {}, &block)
        raise "Reentrant timers do not work in dynamically generated code" unless block.source_location

        @id = id
        @reentrant_id = self.class.reentrant_id(id: id, &block)
        super(duration: duration, thread_locals: thread_locals, &block)
        logger.trace("Created Reentrant Timer #{self} with reentrant Key #{@reentrant_id}")
      end

      def self.reentrant_id(id:, &block)
        [id, block.source_location].flatten
      end
    end
  end
end
