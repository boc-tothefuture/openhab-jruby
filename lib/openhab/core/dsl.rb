# frozen_string_literal: true

require 'java'
require 'core/log'
require 'core/dsl/monkey_patch/events'
require 'core/dsl/monkey_patch/ruby/ruby'
require 'core/dsl/monkey_patch/items/items'
require 'core/dsl/monkey_patch/types/types'
require 'core/dsl/monkey_patch/actions/actions'
require 'core/dsl/rule/rule'
require 'core/dsl/actions'
require 'core/dsl/timers'
require 'core/dsl/group'
require 'core/dsl/things'
require 'core/dsl/items/items'
require 'core/dsl/items/number_item'
require 'core/dsl/time_of_day'
require 'core/dsl/gems'
require 'core/dsl/units'
require 'core/dsl/types/quantity'
require 'core/dsl/states'
require 'core/dsl/persistence'

module OpenHAB
  #
  #  Holds core functions for OpenHAB Helper Library
  #
  module Core
    #
    # Module to be extended to access the OpenHAB Ruby DSL
    #
    module DSL
      # Extend the calling module/class with the DSL
      # rubocop: disable Metrics/MethodLength
      def self.extended(base)
        base.send :include, OpenHAB::Core::DSL::Rule
        base.send :include, OpenHAB::Core::DSL::Items
        base.send :include, OpenHAB::Core::DSL::Types
        base.send :include, OpenHAB::Core::DSL::Groups
        base.send :include, OpenHAB::Core::DSL::Units
        base.send :include, OpenHAB::Core::DSL::Actions
        base.send :include, OpenHAB::Core::DSL::Timers
        base.send :include, OpenHAB::Core::DSL::States
        base.send :include, OpenHAB::Core::DSL::Tod
        base.send :include, OpenHAB::Core::DSL::Persistence
        base.send :include, Things
      end
      # rubocop: enable Metrics/MethodLength
    end
  end
end
