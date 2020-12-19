# frozen_string_literal: true

require 'pp'
require 'java'
require 'set'
require 'core/dsl/monkey_patch/things'
require 'core/dsl/group'
require 'core/dsl/items/number_item'
require 'core/dsl/items/string_item'

# Automation lookup and injection of OpenHab entities
java_import org.openhab.core.items.GroupItem

def Object.const_missing(name)
  EntityLookup.lookup_item(name) || EntityLookup.lookup_thing(name) || super
end

module EntityLookup
  def self.decorate_items(*items)
    items.flatten.map do |item|
      case item
      when GroupItem
        group = item
        item = OpenHAB::Core::DSL::Groups::Group.new(Set.new(EntityLookup.decorate_items(item.all_members.to_a)))
        item.group = group
        item
      when Java::Org.openhab.core.library.items::NumberItem
        OpenHAB::Core::DSL::Items::NumberItem.new(item)
      when Java::Org.openhab.core.library.items::StringItem
        OpenHAB::Core::DSL::Items::StringItem.new(item)
      else
        item
      end
    end
  end

  # rubocop: disable Style/GlobalVars
  def self.lookup_thing(name)
    # Conver from : syntax to underscore
    name = name.to_s if name.is_a? Symbol

    # Thing UIDs have at least 3 segements
    return if name.count('_') < 3

    name = name.gsub('_', ':')
    $things.get(Java::OrgOpenhabCoreThing::ThingUID.new(name))
  end
  # rubocop: enable Style/GlobalVars

  # rubocop: disable Style/GlobalVars
  def self.lookup_item(name)
    name = name.to_s if name.is_a? Symbol
    item = $ir.get(name)
    EntityLookup.decorate_items(item).first
  end
  # rubocop: enable Style/GlobalVars

  def method_missing(method, *args, &block)
    return if method.to_s == 'scriptLoaded'
    return if method.to_s == 'scriptUnloaded'

    EntityLookup.lookup_item(method) || EntityLookup.lookup_thing(method) || super
  end
end
