# frozen_string_literal: true

require 'java'

module OpenHAB
  class OSGI
    java_import org.openhab.core.model.script.actions.ScriptExecution
    java_import org.osgi.framework.FrameworkUtil

    #
    # Return all service references
    #
    # @return [Server Reference Bundle] Context for all service references
    #
    def service_references
      bundle_context.getAllServiceReferences(action_service, nil)
    end

    private

    #
    # Get the lookup string for action services
    #
    # @return [String] Lookup string for the action services
    #
    def action_service
      'org.openhab.core.model.script.engine.action.ActionService'
    end

    #
    # Get the bundle context
    #
    # @return [Bundle Context] OSGI Bundle Context
    #
    def bundle_context
      @bundle_context ||= bundle.getBundleContext
    end

    #
    # Get the OSGI Bundle for ScriptExtension Class
    #
    # @return [OSGI Bundle] OSGI Bundle for ScriptExtension class
    #
    def bundle
      # rubocop: disable Style/GlobalVars
      @bundle ||= FrameworkUtil.getBundle($scriptExtension.class)
      # rubocop: enable Style/GlobalVars
    end
  end
end
