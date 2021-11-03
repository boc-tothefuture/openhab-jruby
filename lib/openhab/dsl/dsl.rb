# frozen_string_literal: true

require 'openhab/log/logger'

# the order of these is important
require 'openhab/dsl/types/types'
require 'openhab/dsl/items/items'
require 'openhab/dsl/monkey_patch/ruby/ruby'

require 'openhab/dsl/monkey_patch/events/events'
require 'openhab/dsl/monkey_patch/actions/actions'
require 'openhab/dsl/rules/rule'
require 'openhab/dsl/rules/terse'
require 'openhab/dsl/actions'
require 'openhab/dsl/timers'
require 'openhab/dsl/group'
require 'openhab/dsl/things'
require 'openhab/dsl/between'
require 'openhab/dsl/gems'
require 'openhab/dsl/persistence'
require 'openhab/dsl/units'
require 'openhab/dsl/states'

module OpenHAB
  #
  # Module to be extended to access the OpenHAB Ruby DSL
  #
  module DSL
    # Extend the calling module/class with the DSL
    # Disabling method length because they are all includes
    # rubocop:disable Metrics/MethodLength
    def self.extended(base)
      base.send :include, OpenHAB::DSL::Actions
      base.send :include, OpenHAB::DSL::Between
      base.send :include, OpenHAB::DSL::Groups
      base.send :include, OpenHAB::DSL::Items
      base.send :include, OpenHAB::DSL::Persistence
      base.send :include, OpenHAB::DSL::Rules
      base.send :include, OpenHAB::DSL::Rules::Terse
      base.send :include, OpenHAB::DSL::States
      base.send :include, OpenHAB::DSL::Things
      base.send :include, OpenHAB::DSL::Timers
      base.send :include, OpenHAB::DSL::Between
      base.send :include, OpenHAB::DSL::Types
      base.send :include, OpenHAB::DSL::Units
    end
    # rubocop:enable Metrics/MethodLength
  end
end
