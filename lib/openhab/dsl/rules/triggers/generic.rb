# frozen_string_literal: true

require 'openhab/log/logger'

module OpenHAB
  module DSL
    module Rules
      #
      # Module holds rule triggers
      #
      module Triggers
        include OpenHAB::Log

        #
        # Create a generic trigger given the trigger type uid and a configuration hash
        #
        # @param [Type] Trigger type UID
        # @param [Configuration] A hash containing the trigger configuration entries
        #
        # @return [Trigger] Trigger object
        #
        def trigger(type, attach: nil, **configuration)
          logger.trace("Creating a generic trigger for type(#{type}) with configuration(#{configuration})")
          append_trigger(type, configuration, attach: attach)
        end
      end
    end
  end
end
