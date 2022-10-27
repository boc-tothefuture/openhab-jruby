# frozen_string_literal: true

require_relative "item_event"

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Events
        java_import org.openhab.core.items.events.ItemCommandEvent

        # Adds methods to core OpenHAB ItemCommandEvent to make it more natural in Ruby
        class ItemCommandEvent < ItemEvent
          # @return [Type]
          alias_method :command, :item_command

          # @!method refresh?
          #   Check if == +REFRESH+
          #   @return [Boolean]

          # @!method on?
          #   Check if == +ON+
          #   @return [Boolean]

          # @!method off?
          #   Check if == +OFF+
          #   @return [Boolean]

          # @!method up?
          #   Check if == +UP+
          #   @return [Boolean]

          # @!method down?
          #   Check if == +DOWN+
          #   @return [Boolean]

          # @!method stop?
          #   Check if == +STOP+
          #   @return [Boolean]

          # @!method move?
          #   Check if == +MOVE+
          #   @return [Boolean]

          # @!method increase?
          #   Check if == +INCREASE+
          #   @return [Boolean]

          # @!method decrease?
          #   Check if == +DECREASE+
          #   @return [Boolean]

          # @!method play?
          #   Check if == +PLAY+
          #   @return [Boolean]

          # @!method pause?
          #   Check if == +PAUSE+
          #   @return [Boolean]

          # @!method rewind?
          #   Check if == +REWIND+
          #   @return [Boolean]

          # @!method fast_forward?
          #   Check if == +FASTFORWARD+
          #   @return [Boolean]

          # @deprecated
          # @!parse alias fastforward? fast_forward?

          # @!method next?
          #   Check if == +NEXT+
          #   @return [Boolean]

          # @!method previous?
          #   Check if == +PREVIOUS+
          #   @return [Boolean]
        end
      end
    end
  end
end
