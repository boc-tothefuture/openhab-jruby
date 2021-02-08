# frozen_string_literal: true

require 'pp'
require 'java'
require 'set'
require 'openhab/dsl/group'
require 'openhab/log/logger'
require 'openhab/dsl/items/number_item'
require 'openhab/dsl/items/string_item'

# Automation lookup and injection of OpenHab entities
java_import org.openhab.core.items.GroupItem

module OpenHAB
  module Core
    #
    # Manages access to OpenHAB entities
    #
    module EntityLookup
      include OpenHAB::Log

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
        return if method.to_s == 'scriptLoaded'
        return if method.to_s == 'scriptUnloaded'

        logger.trace("method missing, performing OpenHab Lookup for: #{method}")
        EntityLookup.lookup_entity(method) || super
      end

      #
      # Checks if this method responds to the missing method
      #
      # @param [String] method_name Name of the method to check
      # @param [Boolean] _include_private boolean if private methods should be checked
      #
      # @return [Boolean] true if this object will respond to the supplied method, false otherwise
      #
      def respond_to_missing?(method_name, _include_private = false)
        logger.trace("Checking if OpenHAB entites exist for #{method_name}")
        method_name = method_name.to_s if method_name.is_a? Symbol

        method_name == 'scriptLoaded' ||
          method_name == 'scriptUnloaded' ||
          EntityLookup.lookup_entity(method_name) ||
          super
      end

      #
      # Looks up an OpenHAB entity
      #  items are checked first, then things
      #
      # @param [String] name of entity to lookup in item or thing registry
      #
      # @return [Thing,Item] if found, nil otherwise
      #
      def self.lookup_entity(name)
        lookup_item(name) || lookup_thing(name)
      end

      #
      # Decorate items with Ruby wrappers
      #
      # @param [Array] items Array of items to decorate
      #
      # @return [Array] Array of decorated items
      #
      def self.decorate_items(*items)
        items.flatten.map { |item| decorate_item(item) }
      end

      #
      # Decorate item with Ruby wrappers
      #
      # @param [Object] item the item object to decorate
      #
      # @return [Object] the ruby wrapper for the item
      #
      private_class_method def self.decorate_item(item)
        case item
        when GroupItem
          decorate_group(item)
        when Java::Org.openhab.core.library.items::NumberItem
          OpenHAB::DSL::Items::NumberItem.new(item)
        when Java::Org.openhab.core.library.items::StringItem
          OpenHAB::DSL::Items::StringItem.new(item)
        else
          item
        end
      end

      #
      # Looks up a Thing in the OpenHAB registry replacing '_' with ':'
      #
      # @param [String] name of Thing to lookup in Thing registry
      #
      # @return [Thing] if found, nil otherwise
      #
      def self.lookup_thing(name)
        logger.trace("Looking up thing(#{name})")
        # Convert from : syntax to underscore
        name = name.to_s if name.is_a? Symbol

        # Thing UIDs have at least 3 segements
        return if name.count('_') < 3

        name = name.gsub('_', ':')
        # rubocop: disable Style/GlobalVars
        $things.get(Java::OrgOpenhabCoreThing::ThingUID.new(name))
        # rubocop: enable Style/GlobalVars
      end

      #
      # Lookup OpenHAB items in item registry
      #
      # @param [String] name of item to lookup
      #
      # @return [Item] OpenHAB item if registry contains a matching item, nil othewise
      #
      def self.lookup_item(name)
        logger.trace("Looking up item(#{name})")
        name = name.to_s if name.is_a? Symbol
        # rubocop: disable Style/GlobalVars
        item = $ir.get(name)
        # rubocop: enable Style/GlobalVars
        decorate_item(item)
      end

      #
      # Decorate a group from an item base
      #
      # @param [OpenHAB item] item item to convert to a group item
      #
      # @return [OpenHAB::DSL::Groups::Group] Group created from supplied item
      #
      private_class_method def self.decorate_group(item)
        group = OpenHAB::DSL::Groups::Group.new(Set.new(decorate_items(item.all_members.to_a)))
        group.group = item
        group
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
