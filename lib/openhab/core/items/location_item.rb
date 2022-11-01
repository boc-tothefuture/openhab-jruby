# frozen_string_literal: true

require_relative "generic_item"

module OpenHAB
  module Core
    module Items
      java_import org.openhab.core.library.items.LocationItem

      #
      # A LocationItem can be used to store GPS related information, addresses
      # etc.
      #
      # This is useful for location awareness related functions
      #
      # @!attribute [r] state
      #   @return [PointType, nil]
      #
      # @example Send point commands
      #   Location << '30,20'   # latitude of 30, longitude of 20
      #   Location << {lat: 30, long: 30}
      #   Location << {lat: 30, long: 30, alt: 80}
      #   Location << '30,20,80' # latitude of 30, longitude of 20, altitude of 80
      #   Location << {latitude: 30, longitude: 30}
      #   Location << {latitude: 30, longitude: 30, altitude: 80}
      #   Location << PointType.new('40,20')
      #
      # @example Determine the distance between two locations
      #   logger.info "Distance from Location 1 to Location 2: #{Location1.state - Location2.state}"
      #   logger.info "Distance from Location 1 to Location 2: #{Location1.state - '40,20'}"
      #   logger.info "Distance from Location 1 to Location 2: #{Location1.state - {lat: 40, long: 20}}"
      #   logger.info "Distance from Location 1 to Location 2: #{Location1.state - PointType.new('40,20')}"
      #
      class LocationItem < GenericItem
        # Support conversion to location items from a hash
        # @!visibility private
        def format_type(command)
          return PointType.new(command.to_hash) if command.respond_to?(:to_hash)

          super
        end
      end
    end
  end
end
