# frozen_string_literal: true

require 'java'
require 'openhab/core/log'

module OpenHAB
  #
  # OSGI services interface
  #
  class OSGI
    include Logging

    java_import org.openhab.core.model.script.actions.ScriptExecution
    java_import org.osgi.framework.FrameworkUtil

    #
    # @return [ServiceReferences]
    #
    def self.service_references
      bundle_context.getAllServiceReferences(action_service, nil)
    end

    #
    # @param name [String] The service name
    #
    # @return [Service]
    #
    def self.service(name)
      ref = bundle_context.getServiceReference(name)
      service = bundle_context.getService(ref) if ref
      logger.trace "OSGI service(#{service}) found for '#{name}' using OSGI Service Reference #{ref}"

      service
    end

    def self.action_service
      'org.openhab.core.model.script.engine.action.ActionService'
    end
    private_class_method :action_service

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
