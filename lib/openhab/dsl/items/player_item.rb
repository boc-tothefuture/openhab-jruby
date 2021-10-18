# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.PlayerItem

      # Adds methods to core OpenHAB NumberItem type to make it more natural in
      # Ruby
      class PlayerItem < GenericItem
        remove_method :==

        # @!method play?
        #   Check if the item state == +PLAYING+
        #   @return [Boolean]

        # @deprecated
        # @!parse alias play? playing?

        # @!method paused?
        #   Check if the item state == +PAUSED+
        #   @return [Boolean]

        # @!method rewinding?
        #   Check if the item state == +REWIND+
        #   @return [Boolean]

        # @!method fast_forwarding?
        #   Check if the item state == +FASTFORWARD+
        #   @return [Boolean]

        # @!method play
        #   Send the +PLAY+ command to the item
        #   @return [PlayerItem] +self+

        # @!method pause
        #   Send the +PAUSE+ command to the item
        #   @return [PlayerItem] +self+

        # @!method rewind
        #   Send the +REWIND+ command to the item
        #   @return [PlayerItem] +self+

        # @!method fast_forward
        #   Send the +FASTFORWARD+ command to the item
        #   @return [PlayerItem] +self+

        # @!method next
        #   Send the +NEXT+ command to the item
        #   @return [PlayerItem] +self+

        # @!method previous
        #   Send the +PREVIOUS+ command to the item
        #   @return [PlayerItem] +self+
      end
    end
  end
end
