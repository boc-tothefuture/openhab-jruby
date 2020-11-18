# frozen_string_literal: true

require 'java'
require 'core/dsl/monkey_patch/things'

# Automation lookup and injection of OpenHab entities

# rubocop: disable Style/GlobalVars
def lookup_item(name)
  name = name.to_s if name.is_a? Symbol
  $ir.get(name)
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
  # We monkey patch here on the object because of class loader issues with ThingImpl
  #  thing&.extend(Things)
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
