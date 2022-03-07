# frozen_string_literal: true

require 'forwardable'

module OpenHAB
  module DSL
    module Rules
      #
      # Module holds rule triggers
      #
      module Triggers
        #
        # Class for creating and managing triggers
        #
        class Trigger
          extend Forwardable

          # Provide backwards compatibility for these fields
          delegate :append_trigger => :@rule_triggers

          #
          # Separates groups from items, and flattens any nested arrays of items
          #
          # @param [Array] item_array Array of items passed to a trigger
          #
          # @return [Array] A new flat array with any GroupMembers object left intact
          #
          def self.flatten_items(item_array)
            # we want to support anything that can be flattened... i.e. responds to to_ary
            # we want to be more lenient than only things that are currently Array,
            # but Enumerable is too lenient because Array#flatten won't traverse interior
            # Enumerables
            return item_array unless item_array.find { |item| item.respond_to?(:to_ary) }

            groups, items = item_array.partition { |item| item.is_a?(OpenHAB::DSL::Items::GroupItem::GroupMembers) }
            groups + flatten_items(items.flatten(1))
          end

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
            config = { 'thingUID' => thing.uid.to_s }
            config['status'] = trigger_state_from_symbol(to).to_s if to
            config['previousStatus'] = trigger_state_from_symbol(from).to_s if from
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
            sym.to_s.upcase if (sym.is_a? Symbol) || sym
          end
        end
      end
    end
  end
end
