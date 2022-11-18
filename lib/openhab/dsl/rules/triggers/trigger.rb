# frozen_string_literal: true

require "forwardable"

module OpenHAB
  module DSL
    module Rules
      module Triggers
        # @!visibility private
        #
        # Class for creating and managing triggers
        #
        class Trigger
          extend Forwardable

          delegate append_trigger: :@rule_triggers

          #
          # Creates a new Trigger
          # @param [RuleTrigger] rule_triggers rule trigger information
          def initialize(rule_triggers:)
            @rule_triggers = rule_triggers
          end

          #
          # Create a trigger for a thing
          #
          # @param [Thing] thing to create trigger for
          # @param [Trigger] type trigger to map with thing
          # @param [State] to for thing
          # @param [State] from state of thing
          #
          # @return [Array] Trigger and config for thing
          #
          def trigger_for_thing(thing:, type:, to: nil, from: nil)
            config = { "thingUID" => thing.to_s }
            config["status"] = trigger_state_from_symbol(to).to_s if to
            config["previousStatus"] = trigger_state_from_symbol(from).to_s if from
            [type, config]
          end

          #
          # converts object to upcase string if its a symbol
          #
          # @param [sym] sym potential symbol to convert
          #
          # @return [String] Upcased symbol as string
          #
          def trigger_state_from_symbol(sym)
            sym.to_s.upcase if sym.is_a?(Symbol) || sym
          end
        end
      end
    end
  end
end
