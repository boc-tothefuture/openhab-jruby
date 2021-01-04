# frozen_string_literal: true

require 'java'
require 'core/log'

module OpenHAB
  module Core
    module DSL
      module Things
        include Logging

        # Ruby Delegator for Thing
        class Thing < SimpleDelegator
        end

        class Things < SimpleDelegator
          java_import org.openhab.core.thing.ThingUID
          # rubocop: disable Style/GlobalVars
          def[](uid)
            thing_uid = ThingUID.new(*uid.split(':'))
            thing = $things.get(thing_uid)
            if thing
              logger.trace("Retrieved Thing(#{thing}) from registry for uid: #{uid}")
              Thing.new(thing)
            end
          end
          # rubocop: enable Style/GlobalVars
        end

        # rubocop: disable Style/GlobalVars
        def things
          Things.new($things.getAll.map { |thing| Thing.new(thing) }.to_set)
        end

        # rubocop: enable Style/GlobalVars
      end
    end
  end
end
