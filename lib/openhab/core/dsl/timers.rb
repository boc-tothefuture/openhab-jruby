# frozen_string_literal: true

require 'java'
require 'delegate'
require 'forwardable'

require 'core/duration'

module OpenHAB
  module Core
    module DSL
      module Timers
        java_import org.openhab.core.model.script.actions.ScriptExecution
        java_import java.time.ZonedDateTime

        # Ruby wrapper for OpenHAB Timer
        # This class implements delegator to delegate methods to the OpenHAB timer
        #
        # @author Brian O'Connell
        # @since 2.0.0
        class Timer < SimpleDelegator
          extend Forwardable

          def_delegator :@timer, :is_active, :active?
          def_delegator :@timer, :is_running, :running?
          def_delegator :@timer, :has_terminated, :terminated?

          def initialize(duration:, &block)
            @duration = duration
            @block = proc do
              block.call(self)
            end
            @timer = ScriptExecution.createTimer(ZonedDateTime.now.plus(Java::JavaTime::Duration.ofMillis(@duration.to_ms)), @block)
            super(@timer)
          end

          def reschedule(duration = nil)
            duration ||= @duration
            @timer.reschedule(ZonedDateTime.now.plus(Java::JavaTime::Duration.ofMillis(duration.to_ms)))
          end
        end

        def after(duration, &block)
          Timer.new(duration: duration, &block)
        end
      end
    end
  end
end
