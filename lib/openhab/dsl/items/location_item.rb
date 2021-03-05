# frozen_string_literal: true

require 'java'
require 'forwardable'
require 'openhab/dsl/items/item_command'
require 'openhab/dsl/items/item_delegate'
require 'openhab/dsl/types/point'

module OpenHAB
  module DSL
    module Items
      #
      # Delegator to OpenHAB Location Item
      #
      class LocationItem
        extend OpenHAB::DSL::Items::ItemCommand
        extend OpenHAB::DSL::Items::ItemDelegate
        extend Forwardable

        def_item_delegator :@location_item

        item_type Java::OrgOpenhabCoreLibraryItems::LocationItem

        #
        # Creates a new LocationItem
        #
        # @param [Java::OrgOpenhabCoreLibraryItems::LocationItem] location_item
        #   The OpenHAB LocationItem to delegate to
        #
        def initialize(location_item)
          logger.trace("Wrapping #{location_item}")
          @location_item = location_item

          item_missing_delegate { @location_item }

          super()
        end

        #
        # Determine the distance between two location items
        #
        # @param [Object] location_item
        #
        #
        def distance_from(location_item)
          case location_item
          when LocationItem
            location_item = location_item.respond_to?(:oh_item) ? location_item.oh_item : location_item
            @location_item.distance_from(location_item)
          when Point, PointType then @location_item.state&.distance_from(location_item)
          when String then @location_item.state&.distance_from(Point.new(location_item))
          else
            Raise ArgumentError, "Unexpected argument type #{location_item.class}"
          end
        end
        alias :- distance_from
      end
    end
  end
end
