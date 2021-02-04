# frozen_string_literal: true

require 'pp'
require 'java'
require 'set'
require 'core/dsl/group'
require 'core/dsl/items/number_item'
require 'core/dsl/items/string_item'

# Automation lookup and injection of OpenHab entities
java_import org.openhab.core.items.GroupItem

#
# Implements const_missing to return OpenHAB items or things if mapping to missing name if they exist
#
# @param [String] name Capital string that was not set as a constant and to be looked up
#
# @return [Object] OpenHAB Item or Thing if their name exist in OpenHAB item and thing regestries
#
def Object.const_missing(name)
  EntityLookup.lookup_item(name) || EntityLookup.lookup_thing(name) || super
end

#
# Manages access to OpenHAB entities
#
module EntityLookup
  #
  # Decorate items with Ruby wrappers
  #
  # @param [Array] items Array of items to decorate
  #
  # @return [Array] Array of decorated items
  #
  # rubocop: disable Metrics/MethodLength
  # Disabled line length - case dispatch pattern
  def self.decorate_items(*items)
    items.flatten.map do |item|
      case item
      when GroupItem
        decorate_group(item)
      when Java::Org.openhab.core.library.items::NumberItem
        OpenHAB::Core::DSL::Items::NumberItem.new(item)
      when Java::Org.openhab.core.library.items::StringItem
        OpenHAB::Core::DSL::Items::StringItem.new(item)
      else
        item
      end
    end
  end
  # rubocop: enable Metrics/MethodLength

  #
  # Loops up a Thing in the OpenHAB registry replacing '_' with ':'
  #
  # @param [String] name of Thing to lookup in Thing registry
  #
  # @return [Thing] if found, nil otherwise
  #
  def self.lookup_thing(name)
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
    name = name.to_s if name.is_a? Symbol
    # rubocop: disable Style/GlobalVars
    item = $ir.get(name)
    # rubocop: enable Style/GlobalVars
    EntityLookup.decorate_items(item).first
  end

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

    EntityLookup.lookup_item(method) || EntityLookup.lookup_thing(method) || super
  end

  #
  # Decorate a group from an item base
  #
  # @param [OpenHAB item] item item to convert to a group item
  #
  # @return [OpenHAB::Core::DSL::Groups::Group] Group created from supplied item
  #
  def self.decorate_group(item)
    group = OpenHAB::Core::DSL::Groups::Group.new(Set.new(EntityLookup.decorate_items(item.all_members.to_a)))
    group.group = item
    group
  end
end
