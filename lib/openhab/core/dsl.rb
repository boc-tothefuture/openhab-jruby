# frozen_string_literal: true

require 'java'
require 'core/log'
require 'core/dsl/monkey_patch/number'
require 'core/dsl/monkey_patch/items'
require 'core/dsl/monkey_patch/things'
require 'core/dsl/monkey_patch/events'
require 'core/dsl/rule/rule'
require 'core/dsl/actions'

module DSL
  include Rule
  include Actions
  include Items
  include Things
end
