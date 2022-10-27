# frozen_string_literal: true

require "forwardable"

require_relative "comparable_item"
require "openhab/dsl/types/point_type"

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.LocationItem

      # Adds methods to core OpenHAB NumberItem type to make it more natural in
      # Ruby
      class LocationItem < GenericItem
        extend Forwardable
        include ComparableItem

        # @!visibility private
        def ==(other)
          # need to check if we're referring to the same item before
          # forwarding to <=> (and thus checking equality with state)
          return true if equal?(other) || eql?(other)

          super
        end

        # Support conversion to location items from a hash
        # @!visibility private
        def format_type(command)
          return PointType.new(command.to_hash) if command.respond_to?(:to_hash)

          super
        end

        # Type Coercion
        #
        # Coerce object to a PointType
        #
        # @param [Types::PointType, String] other object to coerce to a
        #   PointType
        #
        # @return [[Types::PointType, Types::PointType]]
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          return [other, nil] unless state?
          return [other, state] if other.is_a?(Types::PointType) || other.respond_to?(:to_str)
        end

        # OpenHAB has this method, but it _only_ accepts PointType, so remove it and delegate
        remove_method :distance_from

        # any method that exists on {Types::PointType} gets forwarded to +state+
        delegate (Types::PointType.instance_methods - instance_methods) => :state
      end
    end
  end
end
