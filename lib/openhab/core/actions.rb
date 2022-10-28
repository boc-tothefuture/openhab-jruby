# frozen_string_literal: true

module OpenHAB
  module Core
    #
    # Module to import and streamline access to OpenHAB actions
    #
    module Actions
      OSGi.services("org.openhab.core.model.script.engine.action.ActionService")&.each do |service|
        java_import service.actionClass.to_s
        logger.trace("Loaded ACTION: #{service.actionClass}")
      end
      # Import common actions
      %w[Exec HTTP Ping].each { |action| java_import "org.openhab.core.model.script.actions.#{action}" }
    end
  end
end
