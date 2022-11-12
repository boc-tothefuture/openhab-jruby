# frozen_string_literal: true

require_relative "generic_item"

module OpenHAB
  module Core
    module Items
      java_import org.openhab.core.library.items.SwitchItem

      #
      # A SwitchItem represents a normal switch that can be ON or OFF.
      # Useful for normal lights, presence detection etc.
      #
      # @!attribute [r] state
      #   @return [OnOffType, nil]
      #
      #
      # @example Turn on all switches in a `Group:Switch` called Switches
      #   Switches.on
      #
      # @example Turn on all switches in a group called Switches that are off
      #   Switches.select(&:off?).each(&:on)
      #
      # @example Switches accept booelan commands (true/false)
      #   # Turn on switch
      #   SwitchItem << true
      #
      #   # Turn off switch
      #   SwitchItem << false
      #
      #   # Turn off switch if any in another group is on
      #   SwitchItem << Switches.any?(&:on?)
      #
      # @example Invert all Switches
      #   items.grep(SwitchItem)
      #        .each(&:toggle)
      #
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
        #   Check if the item state == {ON}
        #   @return [true,false]

        # @!method off?
        #   Check if the item state == {OFF}
        #   @return [true,false]

        # @!method on
        #   Send the {ON} command to the item
        #   @return [SwitchItem] `self`

        # @!method off
        #   Send the {OFF} command to the item
        #   @return [SwitchItem] `self`
      end
    end
  end
end

# @!parse SwitchItem = OpenHAB::Core::Items::SwitchItem
