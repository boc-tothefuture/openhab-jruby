# frozen_string_literal: true

require 'java'
require 'core/log'
require 'core/dsl/monkey_patch/things'
require 'core/dsl/monkey_patch/events'
require 'core/dsl/monkey_patch/ruby/ruby'
require 'core/dsl/monkey_patch/items/items'
require 'core/dsl/monkey_patch/types/types'
require 'core/dsl/rule/rule'
require 'core/dsl/actions'
require 'core/dsl/group'
require 'core/dsl/items/items'
require 'core/dsl/items/number_item'
require 'core/dsl/time_of_day'
require 'core/dsl/gems'
require 'core/dsl/units'
require 'core/dsl/types/quantity'

module DSL
  include OpenHAB::Core::DSL::Rule
  include OpenHAB::Core::DSL::Items
  include OpenHAB::Core::DSL::Types
  include OpenHAB::Core::DSL::Groups
  include OpenHAB::Core::DSL::Units
  include Actions
  include Things
end
