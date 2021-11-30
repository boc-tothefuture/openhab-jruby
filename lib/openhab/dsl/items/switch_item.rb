# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB items
    #
    module Items
      java_import org.openhab.core.library.items.SwitchItem

      # Alias class names for easy is_a? comparisons
      ::Switch = SwitchItem

      # Adds methods to core OpenHAB SwitchItem type to make it more natural in
      # Ruby
      class SwitchItem < GenericItem
        remove_method :==

        def truthy?
          on?
        end

        # Convert boolean commands to ON/OFF
        # @!visibility private
        def format_type(command)
          return Types::OnOffType.from(command) if [true, false].include?(command)

          super
        end

        #
        # Send a command to invert the state of the switch
        #
        # @return [Types::OnOffType] Inverted state
        #
        def toggle
          command(!self)
        end

        #
        # Return the inverted state of the switch: +ON+ if the switch is +OFF+,
        # +UNDEF+ or +NULL+; +OFF+ if the switch is +ON+
        #
        # @return [Types::OnOffType] Inverted state
        #
        def !
          return !state if state?

          ON
        end

        # @!method on?
        #   Check if the item state == +ON+
        #   @return [Boolean]

        # @!method off?
        #   Check if the item state == +OFF+
        #   @return [Boolean]

        # @!method on
        #   Send the +ON+ command to the item
        #   @return [SwitchItem] +self+

        # @!method off
        #   Send the +OFF+ command to the item
        #   @return [SwitchItem] +self+
      end
    end
  end
end
