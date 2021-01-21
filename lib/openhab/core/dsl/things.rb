# frozen_string_literal: true

require 'java'
require 'core/log'

module OpenHAB
  module Core
    module DSL
      #
      # Support for OpenHAB Things
      #
      module Things
        include Logging

        #
        # Ruby Delegator for Thing
        #
        class Thing < SimpleDelegator
        end

        #
        # Wraps all Things in a delegator to underlying set and provides lookup method
        #
        class Things < SimpleDelegator
          java_import org.openhab.core.thing.ThingUID

          # Gets a specific thing by name in the format binding_id:type_id:thing_id
          # @return Thing specified by name or nil if name does not exist in thing registry
          def[](uid)
            thing_uid = ThingUID.new(*uid.split(':'))
            # rubocop: disable Style/GlobalVars
            thing = $things.get(thing_uid)
            # rubocop: enable Style/GlobalVars
            if thing
              logger.trace("Retrieved Thing(#{thing}) from registry for uid: #{uid}")
              Thing.new(thing)
            end
          end
        end

        #
        # Get all things known to OpenHAB
        #
        # @return [Set] of all Thing objects known to openhab
        #
        def things
          # rubocop: disable Style/GlobalVars
          Things.new($things.getAll.map { |thing| Thing.new(thing) }.to_set)
          # rubocop: enable Style/GlobalVars
        end
      end
    end
  end
end
