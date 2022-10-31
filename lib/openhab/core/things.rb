# frozen_string_literal: true

require "delegate"

require "singleton"

module OpenHAB
  module Core
    #
    # Contains the core {Thing} that bindings use to represent connected devices,
    # as well as related infrastructure.
    #
    module Things
      java_import org.openhab.core.thing.ThingStatus

      class << self
        # @!visibility private
        def manager
          @manager ||= OSGi.service("org.openhab.core.thing.ThingManager")
        end
      end

      #
      # The core class that bindings use to represent connected devices.
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
        # @return [true,false] true if the thing status matches the name
        #
        ThingStatus.constants.each do |thingstatus|
          define_method("#{thingstatus.to_s.downcase}?") { status == ThingStatus.value_of(thingstatus) }
        end

        # Returns the list of channels associated with this Thing
        # @return [Array] channels
        def channels
          ChannelsArray.new(super.to_a)
        end

        # Enable the Thing
        def enable(enabled: true)
          Things.manager.set_enabled(uid, enabled)
        end

        # Disable the Thing
        def disable
          enable(enabled: false)
        end

        private

        #
        # Define methods from actions mapped to this thing
        #
        #
        def define_action_methods
          actions_for_thing(uid).each do |action|
            methods = action.java_class.declared_instance_methods
            methods.each do |method|
              if method.annotation_present?(org.openhab.core.automation.annotation.RuleAction.java_class)
                define_action_method(action: action, method: method.name)
              end
            end
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
    end
  end
end
