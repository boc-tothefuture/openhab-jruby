# frozen_string_literal: true

require_relative "metadata"
require_relative "persistence"
require_relative "semantics"

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.items.GenericItem

      # Adds methods to core OpenHAB GenericItem type to make it more natural in
      # Ruby
      #
      # @see https://www.openhab.org/javadoc/latest/org/openhab/core/items/genericitem
      class GenericItem
        include Log

        prepend Metadata
        prepend Persistence
        include Semantics

        # rubocop:disable Naming/MethodName these mimic Java fields, which are
        # actually methods
        class << self
          # manually define this, since the Java side doesn't
          # @!visibility private
          def ACCEPTED_COMMAND_TYPES
            [org.openhab.core.types.RefreshType.java_class].freeze
          end

          # manually define this, since the Java side doesn't
          # @!visibility private
          def ACCEPTED_DATA_TYPES
            [org.openhab.core.types.UnDefType.java_class].freeze
          end

          # @!visibility private
          #
          # Override to support ItemProxy
          #
          def ===(other)
            other.instance_of?(self)
          end
        end
        # rubocop:enable Naming/MethodName

        alias_method :hash, :hash_code

        # Get the raw item state.
        #
        # The state of the item, including possibly +NULL+ or +UNDEF+
        #
        # @return [Types::Type]
        #
        alias_method :raw_state, :state

        #
        # Send a command to this item
        #
        # @param [Types::Type] command to send to object
        # @return [self]
        #
        def command(command)
          command = format_type_pre(command)
          logger.trace "Sending Command #{command} to #{name}"
          org.openhab.core.model.script.actions.BusEvent.sendCommand(self, command)
          self
        end

        # not an alias to allow easier stubbing and overriding
        def <<(command)
          command(command)
        end

        # @!parse alias_method :<<, :command

        #
        # Send an update to this item
        #
        # @param [Types::Type] update the item
        # @return [self]
        #
        def update(update)
          update = format_type_pre(update)
          logger.trace "Sending Update #{update} to #{name}"
          org.openhab.core.model.script.actions.BusEvent.postUpdate(self, update)
          self
        end

        #
        # Check if the item has a state (not +UNDEF+ or +NULL+)
        #
        # @return [true, false]
        #
        def state?
          !raw_state.is_a?(Types::UnDefType)
        end

        #
        # Get the item state
        #
        # @return [Types::Type, nil]
        #   OpenHAB item state if state is not +UNDEF+ or +NULL+, nil otherwise
        #
        def state
          raw_state if state?
        end

        alias_method :to_s, :name

        #
        # Inspect the item
        #
        # @return [String] details of the item
        #
        def inspect
          to_string
        end

        #
        # Return all groups that this item is part of
        #
        # @return [Array<Group>] All groups that this item is part of
        #
        def groups
          group_names.map { |name| Groups.groups[name] }.compact
        end

        # Return the item's thing if this item is linked with a thing. If an item is linked to more than one thing,
        # this method only returns the first thing.
        #
        # @return [Thing] The thing associated with this item or nil
        def thing
          all_linked_things.first
        end
        alias_method :linked_thing, :thing

        # Returns all of the item's linked things.
        #
        # @return [Array<Thing>] An array of things or an empty array
        def things
          registry = OpenHAB::Core::OSGi.service("org.openhab.core.thing.link.ItemChannelLinkRegistry")
          channels = registry.get_bound_channels(name).to_a
          channels.map(&:thing_uid).uniq.map { |tuid| OpenHAB::DSL::Things.things[tuid] }.compact
        end
        alias_method :all_linked_things, :things

        # @!method null?
        #   Check if the item state == +NULL+
        #   @return [Boolean]

        # @!method undef?
        #   Check if the item state == +UNDEF+
        #   @return [Boolean]

        # @!method refresh
        #   Send the +REFRESH+ command to the item
        #   @return [GenericItem] +self+

        # formats a {Types::Type} to send to the event bus
        # @!visibility private
        def format_type(command)
          # actual Type types can be sent directly without conversion
          return command if command.is_a?(Types::Type)

          command.to_s
        end

        private

        # convert items to their state before formatting, so that subclasses
        # only have to deal with Types
        def format_type_pre(command)
          command = command.state if command.is_a?(GenericItem)
          format_type(command)
        end
      end
    end
  end
end
