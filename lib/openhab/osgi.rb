# frozen_string_literal: true

require 'java'

module OpenHAB
  class OSGI
    java_import org.openhab.core.model.script.actions.ScriptExecution
    java_import org.osgi.framework.FrameworkUtil

    def service_references
      bundle_context.getAllServiceReferences(action_service, nil)
    end

    private

    def action_service
      'org.openhab.core.model.script.engine.action.ActionService'
    end

    def bundle_context
      @bundle_context ||= bundle.getBundleContext
    end

    # Get the OSGI Bundle for ScriptExtension Class
    def bundle
      @bundle ||= FrameworkUtil.getBundle($scriptExtension.class)
    end
  end
end
