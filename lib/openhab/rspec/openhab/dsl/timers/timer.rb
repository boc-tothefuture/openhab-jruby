# frozen_string_literal: true

require "timecop"

module OpenHAB
  module DSL
    class Timer
      module MockedZonedDateTime
        def now
          mocked_time_stack_item = Timecop.top_stack_item
          return super unless mocked_time_stack_item

          instant = java.time.Instant.of_epoch_milli((Time.now.to_f * 1000).to_i)
          ZonedDateTime.of_instant(instant, java.time.ZoneId.system_default)
        end
      end
      ZonedDateTime.singleton_class.prepend(MockedZonedDateTime)

      # extend Timecop to support java time classes
      module TimeCopStackItem
        def parse_time(*args)
          if args.length == 1 && args.first.is_a?(Duration)
            return time_klass.at(ZonedDateTime.now.plus(args.first).to_instant.to_epoch_milli / 1000.0)
          end

          super
        end
      end
      Timecop::TimeStackItem.prepend(TimeCopStackItem)

      attr_reader :execution_time

      def initialize(duration:, thread_locals: {}, &block) # rubocop:disable Lint/UnusedMethodArgument
        @block = block
        reschedule(duration)
      end

      def reschedule(duration = nil)
        @duration = duration || @duration
        @execution_time = DSL.to_zdt(@duration)
        @executed = @cancelled = false

        Timers.timer_manager.add(self)
      end

      def execute
        raise "Timer already cancelled" if cancelled?
        raise "Timer already executed" if terminated?

        @block.call(self)
        Timers.timer_manager.delete(self)
        @executed = true
      end

      def cancel
        Timers.timer_manager.delete(self)
        @executed = false
        @cancelled = true
        true
      end

      def cancelled?
        @cancelled
      end

      def terminated?
        @executed || @cancelled
      end

      def running?
        active? && @execution_time > ZonedDateTime.now
      end

      def active?
        !terminated?
      end
      alias_method :is_active, :active?
    end

    module Support
      class TimerManager
        def execute_timers
          @timers.each { |t| t.execute if t.active? && t.execution_time < ZonedDateTime.now }
        end
      end
    end
  end
end
