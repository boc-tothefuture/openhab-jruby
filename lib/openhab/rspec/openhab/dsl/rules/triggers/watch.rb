# frozen_string_literal: true

module OpenHAB
  module DSL
    module Rules
      module Triggers
        def watch(path, glob: "*", for: %i[created deleted modified], attach: nil); end
      end
    end
  end
end
