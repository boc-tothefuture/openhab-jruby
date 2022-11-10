# frozen_string_literal: true

module OpenHAB
  module Core
    module Things
      class Thing
        @proxies = {}

        class << self
          # ensure each item only has a single proxy, so that
          # expect(item).to receive(:method) works
          def new(thing)
            return super unless defined?(::RSpec) && ::RSpec.current_example&.example_group&.consistent_proxies?

            @proxies.fetch(thing.uid.to_s) do
              @proxies[thing.uid.to_s] = super
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
