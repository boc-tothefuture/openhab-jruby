# frozen_string_literal: true

require "singleton"

module OpenHAB
  module RSpec
    module Mocks
      class SafeCaller
        include Singleton
        include org.openhab.core.common.SafeCaller

        class Builder
          include org.openhab.core.common.SafeCallerBuilder

          def initialize(target)
            @target = target
          end

          def build
            @target
          end

          def chain(*)
            self
          end

          alias_method :withTimeout, :chain
          alias_method :withIdentifier, :chain
          alias_method :onException, :chain
          alias_method :onTimeout, :chain
          alias_method :withAsync, :chain
        end

        def create(target, _klass)
          Builder.new(target)
        end
      end
    end
  end
end
