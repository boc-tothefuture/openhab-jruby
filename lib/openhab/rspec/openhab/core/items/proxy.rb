# frozen_string_literal: true

module OpenHAB
  module Core
    module Items
      class Proxy
        @proxies = {}

        class << self
          # ensure each item only has a single proxy, so that
          # expect(item).to receive(:method) works
          def new(item)
            return super unless defined?(::RSpec) && ::RSpec.current_example&.example_group&.consistent_proxies?

            @proxies.fetch(item.name) do
              @proxies[item.name] = super
            end
          end

          def reset_cache
            @proxies = {}
          end
        end
      end
    end
  end
end
