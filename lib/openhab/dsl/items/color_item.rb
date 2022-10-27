# frozen_string_literal: true

require "forwardable"

require_relative "comparable_item"
require "openhab/dsl/types/hsb_type"

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.ColorItem

      # Adds methods to core OpenHAB ColorItem type to make it more natural in
      # Ruby
      class ColorItem < DimmerItem
        extend Forwardable
        include ComparableItem

        # @!visibility private
        def ==(other)
          # need to check if we're referring to the same item before
          # forwarding to <=> (and thus checking equality with state)
          return true if equal?(other) || eql?(other)

          super
        end

        #
        # Type Coercion
        #
        # Coerce object to a HSBType
        #
        # @param [Types::HSBType, String] other object to coerce to a
        #   HSBType
        #
        # @return [[Types::HSBType, Types::HSBType]]
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          return [other, nil] unless state?
          return [other, state] if other.is_a?(Types::HSBType) || other.respond_to?(:to_str)
        end

        # any method that exists on {Types::HSBType} gets forwarded to +state+
        delegate (Types::HSBType.instance_methods - instance_methods) => :state

        # string commands aren't allowed on ColorItems, so try to implicitly
        # convert it to an HSBType
        # @!visibility private
        def format_type(command)
          return format_hash(command.to_hash) if command.respond_to?(:to_hash)
          return Types::HSBType.new(command) if command.respond_to?(:to_str)

          super
        end

        private

        # Mapping of hash values sets to conversion methods
        HASH_KEYS = { %i[r g b] => :from_rgb,
                      %i[red green blue] => :from_rgb,
                      %i[h s b] => :from_hsb,
                      %i[hue saturation brightness] => :from_hsb }.freeze

        def format_hash(hash)
          hash = hash.transform_keys(&:to_sym)
          HASH_KEYS.each do |key_set, method|
            values = hash.values_at(*key_set).compact
            return Types::HSBType.public_send(method, *values) if values.length == 3
          end
          raise ArgumentError, "Supplied hash (#{hash}) must contain one of the following keysets #{keys.keys}"
        end
      end
    end
  end
end
