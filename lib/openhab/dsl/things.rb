# frozen_string_literal: true

require 'java'
require 'openhab/log/logger'
require 'openhab/dsl/actions'
require 'delegate'
require 'singleton'

module OpenHAB
  module DSL
    #
    # Support for OpenHAB Things
    #
    module Things
      java_import Java::OrgOpenhabCoreThing::ThingStatus
      include OpenHAB::Log

      #
      # Ruby Delegator for Thing
      #
      class Thing < SimpleDelegator
        include OpenHAB::DSL::Actions
        include OpenHAB::Log

        def initialize(thing)
          super
          define_action_methods
        end

        #
        # Defines boolean thing status methods
        #   uninitialized?
        #   initializing?
        #   unknown?
        #   online?
        #   offline?
        #   removing?
        #   removed?
        #
        # @return [Boolean] true if the thing status matches the name
        #
        ThingStatus.constants.each do |thingstatus|
          define_method("#{thingstatus.to_s.downcase}?") { status == ThingStatus.value_of(thingstatus) }
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
      class Things
        java_import org.openhab.core.thing.ThingUID

        include Enumerable
        include Singleton

        # Gets a specific thing by name in the format binding_id:type_id:thing_id
        # @return Thing specified by name or nil if name does not exist in thing registry
        def [](uid)
          thing_uid = ThingUID.new(*uid.split(':'))
          thing = $things.get(thing_uid) # rubocop: disable Style/GlobalVars
          return unless thing

          logger.trace("Retrieved Thing(#{thing}) from registry for uid: #{uid}")
          Thing.new(thing)
        end

        alias include? []
        alias key? []

        # Calls the given block once for each Thing, passing that Thing as a
        # parameter. Returns self.
        #
        # If no block is given, an Enumerator is returned.
        def each(&block)
          # ideally we would do this lazily, but until ruby 2.7
          # there's no #eager method to convert back to a non-lazy
          # enumerator
          to_a.each(&block)
          self
        end

        # explicit conversion to array
        # more efficient than letting Enumerable do it
        def to_a
          $things.getAll.map { |thing| Thing.new(thing) } # rubocop: disable Style/GlobalVars
        end
        # implicitly convertible to array
        alias to_ary to_a
      end

      #
      # Get all things known to OpenHAB
      #
      # @return [Things] all Thing objects known to OpenHAB
      #
      def things
        Things.instance
      end
    end
  end
end
