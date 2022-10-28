# frozen_string_literal: true

require_relative "trigger"

module OpenHAB
  module DSL
    module Rules
      module Triggers
        include Log

        #
        # Create a generic trigger given the trigger type uid and a configuration hash
        #
        # @param [Type] type Trigger type UID
        # @param [Object] attach object to be attached to the trigger
        # @param [Configuration] configuration A hash containing the trigger configuration entries
        #
        # @return [Trigger] Trigger object
        #
        def trigger(type, attach: nil, **configuration)
          logger.trace("Creating a generic trigger for type(#{type}) with configuration(#{configuration})")
          Trigger.new(rule_triggers: @rule_triggers).append_trigger(type: type, config: configuration, attach: attach)
        end
      end
    end
  end
end
