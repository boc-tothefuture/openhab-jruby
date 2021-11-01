# frozen_string_literal: true

module OpenHAB
  module DSL
    module Rules
      #
      # Extends OpenHAB events
      #
      module Events
        java_import org.openhab.core.events.AbstractEvent

        # Add attachments to ItemEvent
        class AbstractEvent
          attr_accessor :attachment
        end
      end
    end
  end
end
