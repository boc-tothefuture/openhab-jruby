# frozen_string_literal: true

require 'java'
require 'set'
require 'core/dsl/monkey_patch/things'
require 'core/dsl/group'

# Automation lookup and injection of OpenHab entities
java_import org.openhab.core.items.GroupItem

# rubocop: disable Style/GlobalVars
def lookup_item(name)
  name = name.to_s if name.is_a? Symbol
  item = $ir.get(name)
  if item.is_a? GroupItem
    group = item
    item = OpenHAB::Core::DSL::Groups::Group.new(Set.new(item.all_members))
    item.group = group
  end
  item
end
# rubocop: enable Style/GlobalVars

# rubocop: disable Style/GlobalVars
def lookup_thing(name)
  # Conver from : syntax to underscore
  name = name.to_s if name.is_a? Symbol

  # Thing UIDs have at least 3 segements
  return if name.count('_') < 3

  name = name.gsub('_', ':')
  $things.get(Java::OrgOpenhabCoreThing::ThingUID.new(name))
end
# rubocop: enable Style/GlobalVars

def Object.const_missing(name)
  lookup_item(name) || lookup_thing(name) || super
end

module EntityLookup
  def method_missing(method, *args, &block)
    return if method.to_s == 'scriptLoaded'
    return if method.to_s == 'scriptUnloaded'

    lookup_item(method) || lookup_thing(method) || super
  end
end
