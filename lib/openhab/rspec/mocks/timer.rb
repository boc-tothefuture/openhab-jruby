# frozen_string_literal: true

require "timecop"

module OpenHAB
  module RSpec
    module Mocks
      class Timer < Core::Timer
        # @!visibility private
        module MockedZonedDateTime
          def now
            mocked_time_stack_item = Timecop.top_stack_item
            return super unless mocked_time_stack_item

            instant = java.time.Instant.of_epoch_milli((Time.now.to_f * 1000).to_i)
            ZonedDateTime.of_instant(instant, java.time.ZoneId.system_default)
          end
        end
        ZonedDateTime.singleton_class.prepend(MockedZonedDateTime)

        # extend Timecop to support Java time classes
        # @!visibility private
        module TimeCopStackItem
          def parse_time(*args)
            if args.length == 1 && args.first.is_a?(java.time.temporal.TemporalAmount)
              return time_klass.at((ZonedDateTime.now + args.first).to_f)
            end

            super
          end
        end
        Timecop::TimeStackItem.prepend(TimeCopStackItem)

        attr_reader :execution_time

        def initialize(time, thread_locals: {}, &block) # rubocop:disable Lint/MissingSuper
          @time = time
          @block = block
          @thread_locals = thread_locals
          reschedule(time)
        end

        def reschedule(time = nil)
          @execution_time = new_execution_time(time || @time)
          @executed = false

          DSL::TimerManager.instance.add(self)
        end

        def execute
          raise "Timer already cancelled" if cancelled?
          raise "Timer already executed" if terminated?

          DSL::ThreadLocal.thread_local(**@thread_locals) do
            @block.call(self)
          end
          DSL::TimerManager.instance.delete(self)
          @executed = true
        end

        def cancel
          return false if terminated? || cancelled?

          DSL::TimerManager.instance.delete(self)
          @execution_time = nil
          true
        end

        def cancelled?
          @execution_time.nil?
        end

        def terminated?
          @executed || cancelled?
        end

        def running?
          false
        end

        def active?
          !terminated?
        end
      end
    end
  end
end
