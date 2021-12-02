# frozen_string_literal: true

require 'openhab/dsl/items/metadata'
require 'openhab/dsl/items/persistence'
require 'openhab/dsl/items/semantics'

require_relative 'item_equality'

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
        include ItemEquality

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

          #
          # Override to support ItemProxy
          #
          def ===(other)
            other.instance_of?(self)
          end
        end
        # rubocop:enable Naming/MethodName

        alias hash hash_code

        # Get the raw item state.
        #
        # The state of the item, including possibly +NULL+ or +UNDEF+
        #
        # @return [Types::Type]
        #
        alias raw_state state

        remove_method(:==)

        #
        # Send a command to this item
        #
        # @param [Types::Type] command to send to object
        #
        #
        def command(command)
          command = format_type_pre(command)
          logger.trace "Sending Command #{command} to #{id}"
          org.openhab.core.model.script.actions.BusEvent.sendCommand(self, command)
          self
        end
        alias << command

        #
        # Send an update to this item
        #
        # @param [Types::Type] update the item
        #
        #
        def update(update)
          update = format_type_pre(update)
          logger.trace "Sending Update #{update} to #{id}"
          org.openhab.core.model.script.actions.BusEvent.postUpdate(self, update)
          self
        end

        #
        # Check if the item has a state (not +UNDEF+ or +NULL+)
        #
        # @return [Boolean]
        #
        def state?
          !raw_state.is_a?(Types::UnDefType)
        end
        alias truthy? state?

        #
        # Get the item state
        #
        # @return [Types::Type, nil]
        #   OpenHAB item state if state is not +UNDEF+ or +NULL+, nil otherwise
        #
        def state
          raw_state if state?
        end

        #
        # Get an ID for the item, using the item label if set, otherwise item name
        #
        # @return [String] label if set otherwise name
        #
        def id
          label || name
        end

        #
        # Get the string representation of the state of the item
        #
        # @return [String] State of the item as a string
        #
        def to_s
          raw_state.to_s # call the super state to include UNDEF/NULL
        end

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
        alias linked_thing thing

        # Returns all of the item's linked things.
        #
        # @return [Array] An array of things or an empty array
        def things
          registry = OpenHAB::Core::OSGI.service('org.openhab.core.thing.link.ItemChannelLinkRegistry')
          channels = registry.get_bound_channels(name).to_a
          channels.map(&:thing_uid).uniq.map { |tuid| OpenHAB::DSL::Things.things[tuid] }
        end
        alias all_linked_things things

        #
        # Check equality without type conversion
        #
        # @return [Boolean] if the same Item is represented, without checking
        #   state
        def eql?(other)
          other.instance_of?(self.class) && hash == other.hash
        end

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
