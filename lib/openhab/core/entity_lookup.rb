# frozen_string_literal: true

# Automation lookup and injection of OpenHab entities

module OpenHAB
  module Core
    #
    # Manages access to OpenHAB entities
    #
    module EntityLookup
      #
      # Automatically looks up OpenHAB items and things in appropriate registries
      #
      # @param [method] method Name of item to lookup
      # @param [<Type>] args method arguments
      # @param [<Type>] block supplied to missing method
      #
      # @return [Object] Item or Thing if found in registry
      #
      def method_missing(method, *args, &block)
        logger.trace("method missing, performing OpenHab Lookup for: #{method}")
        EntityLookup.lookup_entity(method) || super
      end

      #
      # Checks if this method responds to the missing method
      #
      # @param [String] method_name Name of the method to check
      # @param [true,false] _include_private boolean if private methods should be checked
      #
      # @return [true,false] true if this object will respond to the supplied method, false otherwise
      #
      def respond_to_missing?(method_name, _include_private = false)
        logger.trace("Checking if OpenHAB entities exist for #{method_name}")
        method_name = method_name.to_s if method_name.is_a?(Symbol)

        method_name == "scriptLoaded" ||
          method_name == "scriptUnloaded" ||
          EntityLookup.lookup_entity(method_name) ||
          super
      end

      #
      # Looks up an OpenHAB entity
      #  items are checked first, then things
      #
      # @!visibility private
      #
      # @param [String] name of entity to lookup in item or thing registry
      #
      # @return [Thing,Item] if found, nil otherwise
      #
      def self.lookup_entity(name)
        lookup_item(name) || lookup_thing(name)
      end

      #
      # Looks up a Thing in the OpenHAB registry replacing '_' with ':'
      #
      # @!visibility private
      #
      # @param [String] name of Thing to lookup in Thing registry
      #
      # @return [Thing] if found, nil otherwise
      #
      def self.lookup_thing(name)
        logger.trace("Looking up thing '#{name}'")
        name = name.to_s if name.is_a?(Symbol)

        if name.is_a?(String)
          # Thing UIDs have at least 3 segments
          return if name.count("_") < 3

          # Convert from _ syntax to :
          name = name.tr("_", ":")
          name = org.openhab.core.thing.ThingUID.new(name)
        end

        result = $things.get(name)
        result = Things::Thing.new(result) if result
        result
      end

      #
      # Lookup OpenHAB items in item registry
      #
      # @!visibility private
      #
      # @param [String] name of item to lookup
      #
      # @return [Item] OpenHAB item if registry contains a matching item, nil othewise
      #
      def self.lookup_item(name)
        logger.trace("Looking up item '#{name}'")
        name = name.to_s if name.is_a?(Symbol)
        item = $ir.get(name)
        Items::Proxy.new(item) unless item.nil?
      end
    end
  end
end

#
# Implements const_missing to return OpenHAB items or things if mapping to missing name if they exist
#
# @param [String] name Capital string that was not set as a constant and to be looked up
#
# @return [Object] OpenHAB Item or Thing if their name exist in OpenHAB item and thing regestries
#
def Object.const_missing(name)
  OpenHAB::Core::EntityLookup.lookup_entity(name) || super
end
