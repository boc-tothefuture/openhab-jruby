# frozen_string_literal: true

require 'delegate'
require 'java'
require 'singleton'

require 'openhab/log/logger'
require 'openhab/dsl/actions'
require 'openhab/dsl/lazy_array'

module OpenHAB
  module DSL
    #
    # Support for OpenHAB Things
    #
    module Things
      java_import org.openhab.core.thing.ThingStatus
      include OpenHAB::Log

      #
      # Ruby Delegator for Thing
      #
      class Thing < SimpleDelegator
        # Array wrapper class to allow searching a list of channels
        # by channel id
        class ChannelsArray < Array
          # Allows indexing by both integer as an array or channel id acting like a hash.
          # @param [Integer, String] index Numeric index or string channel id to search for.
          def [](index)
            if index.respond_to?(:to_str)
              key = index.to_str
              return find { |channel| channel.uid.id == key }
            end

            super
          end
        end

        include OpenHAB::DSL::Actions
        include OpenHAB::Log

        def initialize(thing)
          super
          define_action_methods
        end

        #
        # Case equality
        #
        # @return [Boolean] if the values are of the same thing
        #
        def ===(other) = other.eql?(self)

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

        # Returns the list of channels associated with this Thing
        # @return [Array] channels
        def channels
          ChannelsArray.new(super.to_a)
        end

        private

        java_import org.openhab.core.automation.annotation.RuleAction

        #
        # Define methods from actions mapped to this thing
        #
        #
        def define_action_methods
          actions_for_thing(uid).each do |action|
            methods = action.java_class.declared_instance_methods
            methods.select { |method| method.annotation_present?(RuleAction.java_class) }
                   .each { |method| define_action_method(action:, method: method.name) }
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
        include LazyArray
        include Singleton

        # Gets a specific thing by name in the format binding_id:type_id:thing_id or via the ThingUID
        # @return Thing specified by name/UID or nil if name/UID does not exist in thing registry
        def [](uid)
          uid = generate_thing_uid(uid) unless uid.is_a?(org.openhab.core.thing.ThingUID)
          thing = $things.get(uid) # rubocop: disable Style/GlobalVars
          return unless thing

          logger.trace("Retrieved Thing(#{thing}) from registry for uid: #{uid}")
          Thing.new(thing)
        end
        alias include? []
        alias key? []

        # explicit conversion to array
        def to_a
          $things.getAll.map { |thing| Thing.new(thing) } # rubocop: disable Style/GlobalVars
        end

        private

        # Returns a ThingUID given a string like object
        #
        # @return ThingUID generated by given name
        def generate_thing_uid(uid)
          org.openhab.core.thing.ThingUID.new(*uid.split(':'))
        end
      end

      module_function

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
