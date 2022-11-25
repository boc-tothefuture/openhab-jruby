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
      # @!attribute [r] name
      #   The item's name.
      #   @return [String]
      #
      # @!attribute [r] label
      #   The item's descriptive label.
      #   @return [String, nil]
      #
      class GenericItem
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
          # Override to support Proxy
          #
          def ===(other)
            other.is_a?(self)
          end
        end
        # rubocop:enable Naming/MethodName

        # @!attribute [r] accepted_command_types
        #   @return [Array<Class>] An array of {Command}s that can be sent as commands to this item

        # @!attribute [r] accepted_data_types
        #   @return [Array<Class>] An array of {State}s that can be sent as commands to this item

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
        #   OpenHAB item state if state is not {UNDEF} or {NULL}, nil otherwise.
        #   This makes it easy to use with the
        #   [Ruby safe navigation operator `&.`](https://ruby-doc.org/core-2.6/doc/syntax/calling_methods_rdoc.html)
        #   Use {#undef?} or {#null?} to check for those states.
        #
        def state
          raw_state if state?
        end

        #
        # The item's {#label} if one is defined, otherwise it's {#name}.
        #
        # @return [String]
        #
        def to_s
          label || name
        end

        #
        # @!attribute [r] groups
        #
        # Return all groups that this item is part of
        #
        # @return [Array<Group>] All groups that this item is part of
        #
        def groups
          group_names.map { |name| EntityLookup.lookup_item(name) }.compact
        end

        # rubocop:disable Layout/LineLength

        # @!attribute [r] metadata
        # @return [Metadata::NamespaceHash]
        #
        # Access to the item's metadata.
        #
        # Both the return value of this method as well as the individual
        # namespaces can be treated as Hashes.
        #
        # Examples assume the following items:
        #
        # ```xtend
        # Switch Item1 { namespace1="value" [ config1="foo", config2="bar" ] }
        # String StringItem1
        # ```
        #
        # @example Check namespace's existence
        #   Item1.metadata["namespace"].nil?
        #   Item1.metadata.key?("namespace")
        #
        # @example Access item's metadata value
        #   Item1.metadata["namespace1"].value
        #
        # @example Access namespace1's configuration
        #   Item1.metadata["namespace1"]["config1"]
        #
        # @example Safely search for the specified value - no errors are raised, only nil returned if a key in the chain doesn"t exist
        #   Item1.metadata.dig("namespace1", "config1") # => "foo"
        #   Item1.metadata.dig("namespace2", "config1") # => nil
        #
        # @example Set item's metadata value, preserving its config
        #   # Item1's metadata before: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #   Item1.metadata["namespace1"].value = "new value"
        #   # Item1's metadata after: {"namespace1"=>["new value", {"config1"=>"foo", "config2"=>"bar"]}}
        #
        # @example Set item's metadata config, preserving its value
        #   # Item1's metadata before: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #   Item1.metadata["namespace1"].replace({ "scooby"=>"doo" })
        #   # Item1's metadata after: {"namespace1"=>["value", {scooby="doo"}]}
        #
        # @example Set a namespace to a new value and config in one line
        #   # Item1's metadata before: {"namespace1"=>"value", {"config1"=>"foo", "config2"=>"bar"}}
        #   Item1.metadata["namespace1"] = "new value", { "scooby"=>"doo" }
        #   # Item1's metadata after: {"namespace1"=>["new value", {scooby="doo"}]}
        #
        # @example Set item's metadata value and clear its previous config
        #   # Item1's metadata before: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #   Item1.metadata["namespace1"] = "new value"
        #   # Item1's metadata after: {"namespace1"=>"value" }
        #
        # @example Set item's metadata config, set its value to nil, and wiping out previous config
        #   # Item1's metadata before: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #   Item1.metadata["namespace1"] = { "newconfig"=>"value" }
        #   # Item1's metadata after: {"namespace1"=>{"config1"=>"foo", "config2"=>"bar"}}
        #
        # @example Update namespace1's specific configuration, preserving its value and other config
        #   # Item1's metadata before: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #   Item1.metadata["namespace1"]["config1"] = "doo"
        #   # Item1's metadata will be: {"namespace1"=>["value", {"config1"=>"doo", "config2"=>"bar"}]}
        #
        # @example Add a new configuration to namespace1
        #   # Item1's metadata before: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #   Item1.metadata["namespace1"]["config3"] = "boo"
        #   # Item1's metadata after: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar", config3="boo"}]}
        #
        # @example Delete a config
        #   # Item1's metadata before: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #   Item1.metadata["namespace1"].delete("config2")
        #   # Item1's metadata after: {"namespace1"=>["value", {"config1"=>"foo"}]}
        #
        # @example Add a namespace and set it to a value
        #   # Item1's metadata before: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #   Item1.metadata["namespace2"] = "qx"
        #   # Item1's metadata after: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}], "namespace2"=>"qx"}
        #
        # @example Add a namespace and set it to a value and config
        #   # Item1's metadata before: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #   Item1.metadata["namespace2"] = "qx", { "config1"=>"doo" }
        #   # Item1's metadata after: {"namespace1"=>["value", {"config1"=>"foo", "config2"=>"bar"}], "namespace2"=>["qx", {"config1"=>"doo"}]}
        #
        # @example Enumerate Item1's namespaces
        #   Item1.metadata.each { |namespace, metadata| logger.info("Item1's namespace: #{namespace}=#{metadata}") }
        #
        # @example Add metadata from a hash
        #   Item1.metadata.merge!({"namespace1"=>{"foo", {"config1"=>"baz"} ], "namespace2"=>{"qux", {"config"=>"quu"} ]})
        #
        # @example Merge Item2's metadata into Item1's metadata
        #   Item1.metadata.merge!(Item2.metadata)
        #
        # @example Delete a namespace
        #   Item1.metadata.delete("namespace1")
        #
        # @example Delete all metadata of the item
        #   Item1.metadata.clear
        #
        # @example Does this item have any metadata?
        #   Item1.metadata.any?
        #
        # @example Store another item's state
        #   StringItem1.update "TEST"
        #   Item1.metadata["other_state"] = StringItem1.state
        #
        # @example Store event's state
        #   rule "save event state" do
        #     changed StringItem1
        #     run { |event| Item1.metadata["last_event"] = event.was }
        #   end
        #
        # @example If the namespace already exists: Update the value of a namespace but preserve its config; otherwise create a new namespace with the given value and nil config.
        #   Item1.metadata["namespace"] = "value", Item1.metadata["namespace"]
        #
        # @example Copy another namespace
        #   # Item1's metadata before: {"namespace2"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #   Item1.metadata["namespace"] = Item1.metadata["namespace2"]
        #   # Item1's metadata after: {"namespace2"=>["value", {"config1"=>"foo", "config2"=>"bar"}], "namespace"=>["value", {"config1"=>"foo", "config2"=>"bar"}]}
        #
        def metadata
          @metadata ||= Metadata::NamespaceHash.new(name)
        end
        # rubocop:enable Layout/LineLength

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
          registry = OSGi.service("org.openhab.core.thing.link.ItemChannelLinkRegistry")
          channels = registry.get_bound_channels(name).to_a
          channels.map(&:thing_uid).uniq.map { |tuid| EntityLookup.lookup_thing(tuid) }.compact
        end
        alias_method :all_linked_things, :things

        # @!method null?
        #   Check if the item state == {NULL}
        #   @return [true,false]

        # @!method undef?
        #   Check if the item state == {UNDEF}
        #   @return [true,false]

        # @!method refresh
        #   Send the {REFRESH} command to the item
        #   @return [GenericItem] `self`

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

        # @return [String]
        def inspect
          s = "#<OpenHAB::Core::Items::#{type}Item#{type_details} #{name} #{label.inspect} state=#{raw_state.inspect}"
          s += " category=#{category.inspect}" if category
          s += " tags=#{tags.to_a.inspect}" unless tags.empty?
          s += " groups=#{group_names}" unless group_names.empty?
          meta = metadata.to_h
          s += " metadata=#{meta.inspect}" unless meta.empty?
          "#{s}>"
        end

        private

        # Allows sub-classes to append additional details to the type in an inspect string
        # @return [String]
        def type_details; end
      end
    end
  end
end

# @!parse GenericItem = OpenHAB::Core::Items::GenericItem
