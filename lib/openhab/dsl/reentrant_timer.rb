# frozen_string_literal: true

module OpenHAB
  module DSL
    # A reentrant timer is a timer that is automatically rescheduled
    # when the block it refers to is encountered again
    #
    # @author Brian O'Connell
    class ReentrantTimer < Core::Timer
      class << self
        #
        # Forms a full ID for a timer including its source location.
        #
        # @param [Object] id
        # @param [Proc] block The block to get the source location from
        # @return [Array<Object>] A non-nested array describing the full ID.
        #
        def reentrant_id(id, block)
          [id] + block.source_location
        end
      end
      attr_reader :id, :reentrant_id

      #
      # Create a new Timer Object
      #
      # @param [java.time.temporal.TemporalAmount, #to_zoned_date_time, Proc] time When to execute the timer
      # @param [Block] block Block to execute when timer fires
      #
      def initialize(time, id:, thread_locals: {}, &block)
        raise "Reentrant timers do not work in dynamically generated code" unless block.source_location

        @id = id
        @reentrant_id = self.class.reentrant_id(id, block)
        super(time, thread_locals: thread_locals, &block)
        logger.trace("Created Reentrant Timer #{self} with reentrant Key #{@reentrant_id}")
      end
    end
  end
end
