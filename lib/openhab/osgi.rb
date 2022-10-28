# frozen_string_literal: true

module OpenHAB
  #
  # OSGi services interface
  #
  module OSGi
    class << self
      #
      # @param name [String] The service name
      #
      # @return [Object]
      #
      def service(name)
        ref = bundle_context.get_service_reference(name)
        service = bundle_context.get_service(ref) if ref
        logger.trace "OSGi service(#{service}) found for '#{name}' using OSGi Service Reference #{ref}"

        service
      end

      #
      # @param name [String] The service name
      # @param filter [String] Filter for service names. See https://docs.osgi.org/javadoc/r4v43/core/org/osgi/framework/Filter.html
      #
      # @return [Array<Object>] An array of services
      #
      def services(name, filter: nil)
        bundle_context.get_service_references(name, filter)&.map do |reference|
          bundle_context.get_service(reference)
        end
      end

      private

      #
      # Get the bundle context
      #
      # @return [java::org::osgi::framework::BundleContext] OSGi bundle context
      #
      def bundle_context
        @bundle_context ||= bundle.bundle_context
      end

      # Get the OSGi Bundle for ScriptExtension Class
      def bundle
        @bundle ||= org.osgi.framework.FrameworkUtil.getBundle($scriptExtension.class)
      end
    end
  end
end
