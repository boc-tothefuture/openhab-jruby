# frozen_string_literal: true

module OpenHAB
  module RSpec
    # @!visibility private
    module SuspendRules
      # I'd prefer to prepend a module, but I can't because of
      # https://github.com/jruby/jruby/issues/6966#issuecomment-1172983776
      class ::OpenHAB::DSL::Rules::AutomationRule # rubocop:disable Style/ClassAndModuleChildren
        def execute(mod = nil, inputs = nil)
          if SuspendRules.suspended?
            logger.trace("Skipping execution of #{uid} because rules are suspended.")
            return
          end

          # super
          ::OpenHAB::DSL::ThreadLocal.thread_local(**@thread_locals) do
            logger.trace { "Execute called with mod (#{mod&.to_string}) and inputs (#{inputs.inspect})" }
            logger.trace { "Event details #{inputs["event"].inspect}" } if inputs&.key?("event")
            trigger_conditions(inputs).process(mod: mod, inputs: inputs) do
              event = extract_event(inputs)
              process_queue(create_queue(event), mod, event)
            end
          rescue Exception => e
            raise if defined?(::RSpec) && ::RSpec.current_example.example_group.propagate_exceptions?

            @run_context.send(:logger).log_exception(e)
          end
        end
      end
      # private_constant :AutomationRule
      # DSL::Rules::AutomationRule.prepend(AutomationRule)

      module DSL
        def after(*, **)
          return if SuspendRules.suspended?

          super
        end
      end
      private_constant :DSL
      OpenHAB::DSL.prepend(DSL)

      @suspended = false

      class << self
        # @!visibility private
        def suspend_rules
          old_suspended = @suspended
          @suspended = true
          yield
        ensure
          @suspended = old_suspended
        end

        # @!visibility private
        def suspended?
          @suspended
        end
      end
    end
  end
end
