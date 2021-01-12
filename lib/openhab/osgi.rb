# frozen_string_literal: true

require 'java'

module OpenHAB
  class OSGI
    java_import org.openhab.core.model.script.actions.ScriptExecution
    java_import org.osgi.framework.FrameworkUtil

    def self.service_references
      bundle_context.getAllServiceReferences(action_service, nil)
    end

    def self.service(name)
      ref = bundle_context.getServiceReference(name)
      bundle_context.getService(ref) if ref
    end

    def self.action_service
      'org.openhab.core.model.script.engine.action.ActionService'
    end

    def self.bundle_context
      @bundle_context ||= bundle.getBundleContext
    end
    private_class_method :bundle_context

    # Get the OSGI Bundle for ScriptExtension Class
    def self.bundle
      @bundle ||= FrameworkUtil.getBundle($scriptExtension.class)
    end
    private_class_method :bundle
  end
end
