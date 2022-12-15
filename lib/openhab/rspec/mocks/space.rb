# frozen_string_literal: true

module OpenHAB
  module RSpec
    module Mocks
      module Space
        ::RSpec::Mocks::Space.prepend(self)

        #
        # When setting expectations on {Items::Proxy proxies}, set them against the item
        # themselves, so that it will catch calls against `self` from within the instance.
        #
        def proxy_for(object)
          return super unless ::RSpec.current_example&.example_group&.consistent_proxies?

          object = object.__getobj__ if object.is_a?(Core::Items::Proxy)

          super
        end
      end
    end
  end
end
