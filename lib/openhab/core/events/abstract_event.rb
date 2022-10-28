# frozen_string_literal: true

module OpenHAB
  module Core
    module Events
      java_import org.openhab.core.events.AbstractEvent

      # Add attachments to ItemEvent
      class AbstractEvent
        attr_accessor :attachment
      end
    end
  end
end
