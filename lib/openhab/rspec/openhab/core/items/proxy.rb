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
