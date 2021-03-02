# frozen_string_literal: true

require 'forwardable'
require 'java'
require 'openhab/dsl/items/item_command'
require 'openhab/dsl/items/item_delegate'

module OpenHAB
  module DSL
    module Items
      #
      # Delegator to OpenHAB Player Item
      #
      class PlayerItem
        extend OpenHAB::DSL::Items::ItemCommand
        extend OpenHAB::DSL::Items::ItemDelegate
        extend Forwardable

        def_item_delegator :@player_item

        item_type Java::OrgOpenhabCoreLibraryItems::PlayerItem, :play? => :playing?,
                                                                :pause? => :paused?,
                                                                :rewind? => :rewinding?,
                                                                :fastforward? => :fastforwarding?

        # rubocop: disable Style/Alias
        # Disabled because 'alias' does not work with the dynamically defined methods
        alias_method :fast_forward, :fastforward
        alias_method :fast_forwarding?, :fastforwarding?
        # rubocop: enable Style/Alias

        #
        # Creates a new PlayerItem
        #
        # @param [Java::OrgOpenhabCoreLibraryItems::PlayerItem] player_item
        #   The OpenHAB PlayerItem to delegate to
        #
        def initialize(player_item)
          logger.trace("Wrapping #{player_item}")
          @player_item = player_item

          item_missing_delegate { @player_item }

          super()
        end
      end
    end
  end
end
