# frozen_string_literal: true

require 'java'
require 'openhab/log/logger'

module OpenHAB
  module Core
    #
    # OSGI services interface
    #
    class OSGI
      include OpenHAB::Log

      java_import org.osgi.framework.FrameworkUtil

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

      #
      # @param name [String] The service name
      # @param filter [String] Filter for service names. See https://docs.osgi.org/javadoc/r4v43/core/org/osgi/framework/Filter.html
      #
      # @return [Array] An array of services
      #
      def self.services(name, filter: nil)
        bundle_context.getServiceReferences(name, filter)&.map do |reference|
          bundle_context.getService(reference)
        end
      end

      #
      # Get the bundle context
      #
      # @return [java::org::osgi::framework::BundleContext] OSGI bundle context
      #
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
end
