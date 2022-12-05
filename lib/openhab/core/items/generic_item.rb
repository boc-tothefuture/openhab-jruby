# frozen_string_literal: true

module OpenHAB
  module Core
    module Items
      java_import org.openhab.core.items.GenericItem

      #
      # The abstract base class for all items.
      #
      # @see https://www.openhab.org/javadoc/latest/org/openhab/core/items/genericitem
      #
      class GenericItem
        # @!parse include Item

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
          # Override to support {Proxy}
          #
          # Item.=== isn't actually included (on the Ruby side) into
          # {GenericItem}
          #
          def ===(other)
            other.is_a?(self)
          end
        end
        # rubocop:enable Naming/MethodName

        # @!attribute [r] name
        #   The item's name.
        #   @return [String]

        # @!attribute [r] label
        #   The item's descriptive label.
        #   @return [String, nil]

        alias_method :hash, :hash_code

        # @!attribute [r] raw_state
        #
        # Get the raw item state.
        #
        # The state of the item, including possibly {NULL} or {UNDEF}
        #
        # @return [State]
        #
        alias_method :raw_state, :state

        #
        # Check if the item has a state (not {UNDEF} or {NULL})
        #
        # @return [true, false]
        #
        def state?
          !raw_state.is_a?(Types::UnDefType)
        end

        #
        # @!attribute [r] state
        # @return [State, nil]
        #   openHAB item state if state is not {UNDEF} or {NULL}, nil otherwise.
        #   This makes it easy to use with the
        #   [Ruby safe navigation operator `&.`](https://ruby-doc.org/core-2.6/doc/syntax/calling_methods_rdoc.html)
        #   Use {#undef?} or {#null?} to check for those states.
        #
        def state
          raw_state if state?
        end

        # @!method null?
        #   Check if the item state == {NULL}
        #   @return [true,false]

        # @!method undef?
        #   Check if the item state == {UNDEF}
        #   @return [true,false]

        #
        # Send a command to this item
        #
        # When this method is chained after the {OpenHAB::DSL::Items::Ensure::Ensurable#ensure ensure}
        # method, or issued inside an {OpenHAB::DSL.ensure_states ensure_states} block,
        # the command will only be sent if the item is not already in the same state.
        #
        # @param [Command] command command to send to the item
        # @return [self, nil] nil when `ensure` is in effect and the item was already in the same state,
        #   otherwise the item.
        #
        # @see DSL::Items::TimedCommand#command Timed Command
        # @see OpenHAB::DSL.ensure_states ensure_states
        # @see DSL::Items::Ensure::Ensurable#ensure ensure
        #
        def command(command)
          command = format_command(command)
          logger.trace "Sending Command #{command} to #{name}"
          $events.send_command(self, command)
          Proxy.new(self)
        end

        # not an alias to allow easier stubbing and overriding
        def <<(command)
          command(command)
        end

        # @!parse alias_method :<<, :command

        # @!method refresh
        #   Send the {REFRESH} command to the item
        #   @return [Item] `self`

        #
        # Send an update to this item
        #
        # @param [State] state
        # @return [self, nil] nil when `ensure` is in effect and the item was already in the same state,
        #   otherwise the item.
        #
        def update(state)
          state = format_update(state)
          logger.trace "Sending Update #{state} to #{name}"
          $events.post_update(self, state)
          Proxy.new(self)
        end

        # @!visibility private
        def format_command(command)
          command = format_type(command)
          return command if command.is_a?(Types::Command)

          command = command.to_s
          org.openhab.core.types.TypeParser.parse_command(getAcceptedCommandTypes, command) || command
        end

        # @!visibility private
        def format_update(state)
          state = format_type(state)
          return state if state.is_a?(Types::State)

          state = state.to_s
          org.openhab.core.types.TypeParser.parse_state(getAcceptedDataTypes, state) || state
        end

        # formats a {Types::Type} to send to the event bus
        # @!visibility private
        def format_type(type)
          # actual Type types can be sent directly without conversion
          # make sure to use Type, because this method is used for both
          # #update and #command
          return type if type.is_a?(Types::Type)

          type.to_s
        end
      end
    end
  end
end

# @!parse GenericItem = OpenHAB::Core::Items::GenericItem
