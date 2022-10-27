# frozen_string_literal: true

require "singleton"

module OpenHAB
  module RSpec
    module Mocks
      class BundleResolver
        include org.openhab.core.util.BundleResolver
        include Singleton

        def initialize
          @classes = {}
        end

        def register_class(klass, bundle)
          # ensure we have an individual java class already
          @classes[klass.become_java!] = bundle
        end

        def resolve_bundle(clazz)
          bundle = @classes[clazz]
          return bundle if bundle

          org.osgi.framework.FrameworkUtil.get_bundle(clazz)
        end
      end
    end
  end
end
