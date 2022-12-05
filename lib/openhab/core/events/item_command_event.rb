# frozen_string_literal: true

require_relative "item_event"

module OpenHAB
  module Core
    module Events
      java_import org.openhab.core.items.events.ItemCommandEvent

      # Adds methods to core openHAB ItemCommandEvent to make it more natural in Ruby
      class ItemCommandEvent < ItemEvent
        # @!attribute [r] command
        # @return [Type] The command sent to the item.
        alias_method :command, :item_command

        # @!method refresh?
        #   Check if `self == REFRESH`
        #   @return [true,false]

        # @!method on?
        #   Check if `self == ON`
        #   @return [true,false]

        # @!method off?
        #   Check if `self == OFF`
        #   @return [true,false]

        # @!method up?
        #   Check if `self == UP`
        #   @return [true,false]

        # @!method down?
        #   Check if `self == DOWN`
        #   @return [true,false]

        # @!method stop?
        #   Check if `self == STOP`
        #   @return [true,false]

        # @!method move?
        #   Check if `self == MOVE`
        #   @return [true,false]

        # @!method increase?
        #   Check if `self == INCREASE`
        #   @return [true,false]

        # @!method decrease?
        #   Check if `self == DECREASE`
        #   @return [true,false]

        # @!method play?
        #   Check if `self == PLAY`
        #   @return [true,false]

        # @!method pause?
        #   Check if `self == PAUSE`
        #   @return [true,false]

        # @!method rewind?
        #   Check if `self == REWIND`
        #   @return [true,false]

        # @!method fast_forward?
        #   Check if `self == FASTFORWARD`
        #   @return [true,false]

        # @!method next?
        #   Check if `self == NEXT`
        #   @return [true,false]

        # @!method previous?
        #   Check if `self == PREVIOUS`
        #   @return [true,false]
      end
    end
  end
end
