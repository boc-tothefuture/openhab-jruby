# frozen_string_literal: true

module OpenHAB
  module Core
    module Rules
      #
      # Provides rules created in Ruby to openHAB
      #
      class Provider < Core::Provider
        include org.openhab.core.automation.RuleProvider

        class << self
          #
          # The Rule registry
          #
          # @return [org.openhab.core.automation.RuleRegistry]
          #
          def registry
            $rules
          end
        end

        def initialize
          super(script_unloaded_before: lambda do |callbacks|
            callbacks.index { |cb| cb.binding.receiver.is_a?(Items::Provider) }
          end)
        end
      end
    end
  end
end
