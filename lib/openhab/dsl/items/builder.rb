# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      # Stores all items created in scripts, and notifies the ItemRegistry
      # of their existence
      # @!visibility private
      class ItemProvider < org.openhab.core.common.registry.AbstractProvider
        include org.openhab.core.items.ItemProvider
        include Singleton

        def initialize
          super

          @items = {}

          $ir.add_provider(self)
          OpenHAB::Core::ScriptHandling.script_unloaded { $ir.remove_provider(self) }
        end

        # Add an item to this provider
        def add(builder)
          item = builder.build
          raise "Item #{item.name} already exists" if @items.key?(item.name)

          @items[item.name] = item
          notify_listeners_about_added_element(item)

          # make sure to add the item to the registry before linking it
          if builder.channel
            channel = builder.channel
            if !channel.include?(":") &&
               (group = builder.groups.find { |g| g.is_a?(GroupItemBuilder) && g.thing })
              thing = group.thing
              thing = thing.uid if thing.is_a?(Things::Thing)
              channel = "#{thing}:#{channel}"
            end
            ItemChannelLinkProvider.instance.link(item, channel)
          end

          item
        end

        # Remove an item from this provider
        #
        # @return [GenericItem, nil] The removed item, if found.
        def remove(item_name, recursive: false)
          return nil unless @items.key?(item_name)

          item = @items.delete(item_name)
          if recursive && item.is_a?(GroupItem)
            item.members.each { |member| remove(member.__getobj__, recursive: true) }
          end

          notify_listeners_about_removed_element(item)
          item
        end

        # Get all items in this provider
        def getAll # rubocop:disable Naming/MethodName required by java interface
          @items.values
        end
      end

      # @!visibility private
      class ItemChannelLinkProvider < org.openhab.core.common.registry.AbstractProvider
        include org.openhab.core.thing.link.ItemChannelLinkProvider
        include Singleton

        def initialize
          super

          @links = Hash.new { |h, k| h[k] = Set.new }
          registry = OpenHAB::Core::OSGI.service("org.openhab.core.thing.link.ItemChannelLinkRegistry")
          registry.add_provider(self)
          OpenHAB::Core::ScriptHandling.script_unloaded { registry.remove_provider(self) }
        end

        def link(item, channel, config = {})
          config = org.openhab.core.config.core.Configuration.new(config)
          channel = org.openhab.core.thing.ChannelUID.new(channel) if channel.is_a?(String)
          channel = channel.uid if channel.is_a?(org.openhab.core.thing.Channel)
          link = org.openhab.core.thing.link.ItemChannelLink.new(item.name, channel, config)

          item_links = @links[item.name]
          if item_links.include?(link)
            notify_listeners_about_updated_element(link, link)
          else
            item_links << link
            notify_listeners_about_added_element(link)
          end
        end

        def getAll # rubocop:disable Naming/MethodName required by java interface
          @links.values.flatten
        end
      end

      # An item builder allows you to dynamically create OpenHAB items at runtime.
      # This can be useful either to create items as soon as the script loads,
      # or even later based on a rule executing.
      #
      # @example
      #   items.build do
      #     switch_item "MySwitch", "My Switch"
      #     switch_item "NotAutoupdating", autoupdate: false, channel: "mqtt:topic:1#light"
      #     group_item "MyGroup" do
      #       contact_item "ItemInGroup", channel: "binding:thing#channel"
      #     end
      #     # passing `thing` to a group item will automatically use it as the base
      #     # for item channels
      #     group_item "Equipment", tags: Semantics::HVAC, thing: "binding:thing"
      #       string_item "Mode", tags: Semantics::Control, channel: "mode"
      #     end
      #   end
      module Builder
        class << self
          private

          # @!macro def_item_method
          #   @!method $1_item(name, label = nil, **kwargs)
          #   Create a new $1 item
          #   @param name [String] The name for the new item
          #   @param label [String] The item label
          #   @yield [ItemBuilder] Item for further customization
          #   @return [Item] The Item
          #   @see ItemBuilder#initialize for additional arguments.
          def def_item_method(method)
            class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{method}_item(*args, **kwargs, &block)         # def dimmer_item(*args, **kwargs, &block)
                item(#{method.inspect}, *args, **kwargs, &block)  #   item(:dimmer, *args, **kwargs, &block)
              end
            RUBY
          end
        end

        def_item_method(:color)
        def_item_method(:contact)
        def_item_method(:date_time)
        def_item_method(:dimmer)
        def_item_method(:image)
        def_item_method(:location)
        def_item_method(:number)
        def_item_method(:player)
        def_item_method(:rollershutter)
        def_item_method(:string)
        def_item_method(:switch)

        # Create a new {GroupItem}
        #
        # @!method group_item(name, label = nil, **kwargs)
        # @param name [String] The name for the new item
        # @param label [String] The item label
        # @yield GroupItemBuilder
        # @see GroupItemBuilder#initialize
        def group_item(*args, **kwargs, &block)
          item = GroupItemBuilder.new(*args, provider: provider, **kwargs)
          item.instance_eval(&block) if block
          result = provider.add(item)
          item.members.each do |i|
            provider.add(i)
          end
          result
        end

        include OpenHAB::Core::EntityLookup

        private

        def item(*args, **kwargs, &block)
          item = ItemBuilder.new(*args, provider: provider, **kwargs)
          item.instance_eval(&block) if block
          provider.add(item)
          OpenHAB::Core::ItemProxy.new(item)
        end
      end

      # @!visibility private
      class BaseBuilderDSL
        include Builder

        private

        def provider
          ItemProvider.instance
        end
      end

      # The ItemBuilder DSL allows you to customize an Item
      class ItemBuilder
        # The type of this item
        # @example
        #   type #=> :switch
        # @return [Symbol]
        attr_reader :type
        # Item name
        # @return [String]
        attr_accessor :name
        # Item label
        # @return [String, nil]
        attr_accessor :label
        # Unit dimension (for number items only)
        # @return [String, nil]
        attr_accessor :dimension
        # The formatting pattern for the item's state
        # @return [String, nil]
        attr_accessor :format
        # The icon to be associated with the item
        # @return [Symbol, nil]
        attr_accessor :icon
        # Groups to which this item should be added
        # @return [Array<String, GroupItem>]
        attr_reader :groups
        # Tags to apply to this item
        # @return [Array<String, Semantics::Tag>]
        attr_reader :tags
        # Autoupdate setting
        # @return [true, false, nil]
        attr_accessor :autoupdate
        # Channel to link the item to
        # @return [String, ChannelUID, nil]
        attr_accessor :channel
        # Initial state
        attr_accessor :state

        class << self
          # @!visibility private
          def item_factory
            @item_factory ||= org.openhab.core.library.CoreItemFactory.new
          end
        end

        # @param dimension [Symbol, nil] The unit dimension for a {NumberItem} (see {#dimension})
        # @param format [String, nil] The formatting pattern for the item's state (see {#format})
        # @param icon [Symbol, nil] The icon to be associated with the item (see {#icon})
        # @param groups [String, GroupItem, Array<String, GroupItem>, nil]
        #        Groups to which this item should be added (see {#group})
        # @param tags [String, org.openhab.core.semantics.Tag, Array<String, Semantics::Tag>, nil]
        #        Tags to apply to this item (see {tag})
        # @param alexa [String, Array, nil] Alexa metadata (see {#alexa})
        # @param autoupdate [true, false, nil] Autoupdate setting (see {#autoupdate})
        # @param channel [String, Things::ChannelUID, nil] Channel to link the item to
        # @param expire [String] An expiration specification.
        # @param homekit [String, Array, nil] Homekit metadata (see {#alexa})
        # @param metadata [Hash{String=>Hash}] Generic metadata (see {#metadata})
        # @param state [Types::State] Initial state
        def initialize(type, name = nil, label = nil,
                       provider:,
                       dimension: nil,
                       format: nil,
                       icon: nil,
                       groups: nil,
                       tags: nil,
                       alexa: nil,
                       autoupdate: nil,
                       channel: nil,
                       expire: nil,
                       homekit: nil,
                       metadata: nil,
                       state: nil)
          raise ArgumentError, "Dimension can only be specified with NumberItem" if dimension && type != :number

          if provider.is_a?(GroupItemBuilder)
            name = "#{provider.name_base}#{name}"
            label = "#{provider.label_base}#{label}".strip if label
          end
          @provider = provider
          @type = type
          @name = name
          @label = label
          @dimension = dimension
          @format = format
          @icon = icon
          @groups = groups || []
          @tags = []
          @metadata = metadata || {}
          @autoupdate = autoupdate
          metadata("alexa", alexa) if alexa
          @channel = channel
          @expire = nil
          self.expire(*Array(expire)) if expire
          metadata("homekit", homekit) if homekit
          @state = state

          (tags || []).each do |tag|
            self.tag(tag)
          end
        end

        # Tag item
        # @param tag [String, org.openhab.core.semantics.Tag]
        def tag(tag)
          tag = tag.name.split("::").last if tag.is_a?(Module) && tag < org.openhab.core.semantics.Tag
          @tags << tag.to_s
        end

        # Add this item to a group
        # @param group [String, GroupItemBuilder, GroupItem]
        def group(group)
          @groups << group
        end

        # Shortcut for adding Homekit metadata
        #
        # @see https://www.openhab.org/addons/integrations/homekit/
        #
        # @param value [String] Type of Homekit accessory or characteristic
        # @param config [Hash] Additional Homekit configuration
        def homekit(value = nil, config = nil)
          metadata("homekit", value, config)
        end

        # Shortcut for adding Alexa metadata
        #
        # @see https://www.openhab.org/docs/ecosystem/alexa/
        #
        # @param value [String] Type of Alexa endpoint
        # @param config [Hash] Additional Alexa configuration
        def alexa(value = nil, config = nil)
          metadata("alexa", value, config)
        end

        # Add or metadata
        # @example Retrieve the full metadata hash
        #    metadata # => { "homekit" => "Switchable" }
        # @example Retrieve the metadata for a specific key
        #    metadata["homekit"] # => "Switchable"
        def metadata(*args)
          unless (0..3).cover?(args.length)
            raise ArgumentError,
                  "wrong number of arguments (given #{args.length}, expected 0..3)"
          end
          return @metadata if args.empty?

          namespace, value, config = *args
          return @metadata[namespace] if value.nil? && config.nil?

          @metadata[namespace] = if config.nil?
                                   value
                                 else
                                   [value, config]
                                 end
        end

        # @!method expire(command: nil, state: nil)
        #
        # Configure item expiration
        #
        # @example Get the current expire setting
        #   expire
        # @example Clear any expire setting
        #   expire nil
        # @example Use a duration
        #   expire 5.hours
        # @example Use a string duration
        #   expire "5h"
        # @example Set a specific state on expiration
        #   expire 5.minutes, NULL
        #   expire 5.minutes, state: NULL
        # @example Send a command on expiration
        #   expire 5.minutes, command: OFF
        def expire(*args, command: nil, state: nil)
          unless (0..2).cover?(args.length)
            raise ArgumentError,
                  "wrong number of arguments (given #{args.length}, expected 0..2)"
          end
          return @expire if args.empty?

          state = args.last if args.length == 2
          raise ArgumentError, "cannot provide both command and state" if command && state

          duration = args.first
          return @expire = nil if duration.nil?

          duration = duration.to_s[2..].downcase if duration.is_a?(java.time.Duration)
          state = "'#{state}'" if state.respond_to?(:to_str) && type == :string
          @expire = duration
          @expire += ",state=#{state}" if state
          @expire += ",command=#{command}" if command
        end

        # @!visibility private
        def build
          item = create_item
          item.label = label
          item.category = icon.to_s if icon
          groups.each do |group|
            group = group.name if group.is_a?(GroupItemBuilder)
            group = $ir.get(group) if group.is_a?(String)
            next unless group

            group.add_member(item)
          end
          tags.each do |tag|
            item.add_tag(tag)
          end
          metadata.each do |namespace, data|
            process_meta(item, namespace, data)
          end
          item.meta["autoupdate"] = autoupdate.to_s unless autoupdate.nil?
          item.meta["expire"] = expire if expire
          item.meta["stateDescription"] = { "pattern" => format } if format
          unless state.nil?
            state = self.state
            state = item.__send__(:format_type_pre, state) unless state.is_a?(org.openhab.core.types.State)
            unless state.is_a?(org.openhab.core.types.State)
              state = org.openhab.core.types.TypeParser.parse_state(item.accepted_data_types, state.to_s)
            end
            item.state = state
          end
          item
        end

        private

        def create_item
          type = @type.to_s.gsub(/(?:^|_)[a-z]/) { |match| match[-1].upcase }
          type = "#{type}:#{dimension}" if dimension
          self.class.item_factory.create_item(type, name)
        end

        def process_meta(item, namespace, data)
          case data
          when String
            value = data
          when Hash
            config = data
          when Array
            value = data.first
            config = data.last
            unless data.length == 2
              raise ArgumentError,
                    "Metadata array must be a string, a hash, or an array of a string and hash"
            end
          else
            unless data.length == 2
              raise ArgumentError,
                    "Metadata array must be a string, a hash, or an array of a string and hash"
            end
          end
          config ||= {}
          item.meta[namespace] = config
          item.meta[namespace].value = value
        end
      end

      # Allows customizing a group. You can also call any method from {Builder}, and those
      # items will automatically be a member of this group.
      class GroupItemBuilder < ItemBuilder
        include Builder
        Builder.public_instance_methods.each do |m|
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{m}(*args, groups: nil, **kwargs)  # def dimmer_item(*args, groups: nil, **kwargs)
              groups ||= []                         #   groups ||= []
              groups << self                        #   groups << self
              super                                 #   super
            end                                     # end
          RUBY
        end

        FUNCTION_REGEX = /^([a-z]+)(?:\(([a-z]+)(?:,([a-z]+))*\))?/i.freeze
        private_constant :FUNCTION_REGEX

        # The combiner function for this group
        # @return [String, nil]
        attr_accessor :function
        # A thing to be used as the base for the channel of any member items
        # @return [ThingUID, Thing, String, nil]
        attr_accessor :thing
        # A prefix to be added to the name of any member items
        # @return [String, nil]
        attr_accessor :name_base
        # A prefix to be added to the label of any member items
        # @return [String, nil]
        attr_accessor :label_base
        # Members to be created in this group
        # @return [Array<ItemBuilder>]
        attr_reader :members

        # @param type [Symbol, nil] The base type for the group
        # @param function [String, nil] The combiner function for this group
        # @param thing [ThingUID, Thing, String, nil]
        #        A Thing to be used as the base for the channel for any contained items.
        # @param kwargs [] Additional parameters
        # @see ItemBuilder#initialize
        def initialize(*args, type: nil, function: nil, thing: nil, **kwargs)
          raise ArgumentError, "invalid function #{function}" if function && !function.match?(FUNCTION_REGEX)
          raise ArgumentError, "state cannot be set on GroupItems" if kwargs[:state]

          super(type, *args, **kwargs)
          @function = function
          @members = []
          @thing = thing
        end

        # @!visibility private
        def create_item
          base_item = super if type
          if function
            match = function.match(FUNCTION_REGEX)

            dto = org.openhab.core.items.dto.GroupFunctionDTO.new
            dto.name = match[1]
            dto.params = match[2..]
            function = org.openhab.core.items.dto.ItemDTOMapper.map_function(base_item, dto)
          end
          GroupItem.new(name, base_item, function)
        end

        # @!visibility private
        def add(child_item)
          @members << child_item
        end

        private

        def provider
          self
        end
      end
    end
  end
end
