# frozen_string_literal: true

require_relative "generic_item"

module OpenHAB
  module Core
    module Items
      java_import org.openhab.core.library.items.SwitchItem

      # Adds methods to core OpenHAB SwitchItem type to make it more natural in
      # Ruby
      class SwitchItem < GenericItem
        # Convert boolean commands to ON/OFF
        # @!visibility private
        def format_type(command)
          return Types::OnOffType.from(command) if [true, false].include?(command)

          super
        end

        #
        # Send a command to invert the state of the switch
        #
        # @return [self]
        #
        def toggle
          return on unless state?

          command(!state)
        end

        # @!method on?
        #   Check if the item state == `ON`
        #   @return [true,false]

        # @!method off?
        #   Check if the item state == `OFF`
        #   @return [true,false]

        # @!method on
        #   Send the `ON` command to the item
        #   @return [SwitchItem] `self`

        # @!method off
        #   Send the `OFF` command to the item
        #   @return [SwitchItem] `self`
      end
    end
  end
end
