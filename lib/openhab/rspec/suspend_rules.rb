# frozen_string_literal: true

module OpenHAB
  module RSpec
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
          DSL.import_presets
          thread_local(RULE_NAME: name) do
            logger.trace { "Execute called with mod (#{mod&.to_string}) and inputs (#{inputs.inspect})" }
            logger.trace { "Event details #{inputs["event"].inspect}" } if inputs&.key?("event")
            trigger_conditions(inputs).process(mod: mod, inputs: inputs) do
              process_queue(create_queue(inputs), mod, inputs)
            end
          end
        end
      end
      # private_constant :AutomationRule
      # DSL::Rules::AutomationRule.prepend(AutomationRule)

      module Timers
        def after(*)
          return if SuspendRules.suspended?

          super
        end
      end
      private_constant :Timers
      ::Object.prepend(Timers)

      @suspended = false

      class << self
        def suspend_rules
          old_suspended = @suspended
          @suspended = true
          yield
        ensure
          @suspended = old_suspended
        end

        def suspended?
          @suspended
        end
      end
    end
  end
end
