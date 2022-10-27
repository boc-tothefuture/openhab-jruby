# frozen_string_literal: true

require "delegate"

module OpenHAB
  module RSpec
    module Mocks
      class BundleInstallSupport < SimpleDelegator
        include org.apache.karaf.features.internal.service.BundleInstallSupport

        def initialize(parent, karaf_wrapper)
          super(parent)
          @karaf_wrapper = karaf_wrapper
        end

        def set_bundle_start_level(bundle, _start_level)
          return if @karaf_wrapper.send(:blocked_bundle?, bundle)

          super
        end
      end
    end
  end
end
