# frozen_string_literal: true

module OpenHAB
  module DSL
    module Things
      class Thing
        @proxies = {}

        class << self
          # ensure each item only has a single proxy, so that
          # expect(item).to receive(:method) works
          def new(thing)
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
