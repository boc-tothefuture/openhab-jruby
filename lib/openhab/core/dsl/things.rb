# frozen_string_literal: true

require 'java'
require 'core/log'
require 'core/dsl/actions'
require 'delegate'

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
          include OpenHAB::Core::DSL::Actions
          include Logging

          def initialize(thing)
            super
            define_action_methods
          end

          private

          java_import 'org.openhab.core.automation.annotation.RuleAction'

          #
          # Define methods from actions mapped to this thing
          #
          #
          def define_action_methods
            actions_for_thing(uid).each do |action|
              methods = action.java_class.declared_instance_methods
              methods.select { |method| method.annotation_present?(RuleAction.java_class) }
                     .each { |method| define_action_method(action: action, method: method.name) }
            end
          end

          #
          # Define a method, delegating to supplied action class
          #
          # @param [Object] action object to delegate method to
          # @param [String] method Name of method to delegate
          #
          #
          def define_action_method(action:, method:)
            logger.trace("Adding action method '#{method}' to thing '#{uid}'")
            define_singleton_method(method) do |*args|
              action.public_send(method, *args)
            end
          end
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
            return unless thing

            logger.trace("Retrieved Thing(#{thing}) from registry for uid: #{uid}")
            Thing.new(thing)
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
