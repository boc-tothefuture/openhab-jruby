# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Contains extensions to simplify working with [GenericItem]s.
    #
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
          ScriptHandling.script_unloaded { $ir.remove_provider(self) }
        end

        # Add an item to this provider
        def add(builder)
          item = builder.build
          raise "Item #{item.name} already exists" if @items.key?(item.name)

          @items[item.name] = item
          notify_listeners_about_added_element(item)

          # make sure to add the item to the registry before linking it
          builder.channels.each do |(channel, config)|
            if !channel.include?(":") &&
               (group = builder.groups.find { |g| g.is_a?(GroupItemBuilder) && g.thing })
              thing = group.thing
              thing = thing.uid if thing.is_a?(Core::Things::Thing)
              channel = "#{thing}:#{channel}"
            end
            ItemChannelLinkProvider.instance.link(item, channel, config)
          end

          item
        end

        # Remove an item from this provider
        #
        # @return [GenericItem, nil] The removed item, if found.
        def remove(item_name, recursive: false)
          return nil unless @items.key?(item_name)

          item = @items.delete(item_name)
          if recursive && item.is_a?(Core::Items::GroupItem)
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
          registry = OSGi.service("org.openhab.core.thing.link.ItemChannelLinkRegistry")
          registry.add_provider(self)
          ScriptHandling.script_unloaded { registry.remove_provider(self) }
        end

        # @!visibility private
        def link(item, channel, config = {})
          config = org.openhab.core.config.core.Configuration.new(config.transform_keys(&:to_s))
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
        include Core::EntityLookup

        class << self
          private

          # @!macro def_item_method
          #   @!method $1_item(name, label = nil, **kwargs)
          #   Create a new $1 item
          #   @param name [String] The name for the new item
          #   @param label [String] The item label
          #   @yieldparam [ItemBuilder] builder Item for further customization
          #   @see ItemBuilder#initialize ItemBuilder#initialize for additional arguments.
          def def_item_method(method)
            class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{method}_item(*args, **kwargs, &block)         # def dimmer_item(*args, **kwargs, &block)
                item(#{method.inspect}, *args, **kwargs, &block)  #   item(:dimmer, *args, **kwargs, &block)
              end
            RUBY
          end
        end

        # @return [ColorItem]
        def_item_method(:color)
        # @return [ContactItem]
        def_item_method(:contact)
        # @return [DateTimeItem]
        def_item_method(:date_time)
        # @return [DimmerItem]
        def_item_method(:dimmer)
        # @return [ImageItem]
        def_item_method(:image)
        # @return [LocationItem]
        def_item_method(:location)
        # @return [NumberItem]
        def_item_method(:number)
        # @return [PlayerItem]
        def_item_method(:player)
        # @return [RollershutterItem]
        def_item_method(:rollershutter)
        # @return [StringItem]
        def_item_method(:string)
        # @return [SwitchItem]
        def_item_method(:switch)

        # Create a new {GroupItem}
        #
        # @!method group_item(name, label = nil, **kwargs)
        # @param name [String] The name for the new item
        # @param label [String] The item label
        # @param (see GroupItemBuilder#initialize)
        # @yieldparam [GroupItemBuilder] builder Item for further customization
        # @return [GroupItem]
        def group_item(*args, **kwargs, &block)
          item = GroupItemBuilder.new(*args, provider: provider, **kwargs)
          item.instance_eval(&block) if block
          result = provider.add(item)
          item.members.each do |i|
            provider.add(i)
          end
          result
        end

        include DSL

        private

        def item(*args, **kwargs, &block)
          item = ItemBuilder.new(*args, provider: provider, **kwargs)
          item.instance_eval(&block) if block
          provider.add(item)
          Core::Items::Proxy.new(item)
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
        # {Core::Things::ChannelUID Channel} to link the item to
        # @return [String, Core::Things::ChannelUID, nil]
        attr_accessor :channels
        # @return [Core::Items::Metadata::NamespaceHash]
        attr_reader :metadata
        # Initial state
        # @return [Core::Types::State]
        attr_accessor :state

        class << self
          # @!visibility private
          def item_factory
            @item_factory ||= org.openhab.core.library.CoreItemFactory.new
          end
        end

        # @param dimension [Symbol, nil] The unit dimension for a {NumberItem} (see {ItemBuilder#dimension})
        # @param format [String, nil] The formatting pattern for the item's state (see {ItemBuilder#format})
        # @param icon [Symbol, nil] The icon to be associated with the item (see {ItemBuilder#icon})
        # @param group [String,
        #   GroupItem,
        #   GroupItemBuilder,
        #   Array<String, GroupItem, GroupItemBuilder>,
        #   nil]
        #        Group(s) to which this item should be added (see {ItemBuilder#group}).
        # @param groups [String,
        #   GroupItem,
        #   GroupItemBuilder,
        #   Array<String, GroupItem, GroupItemBuilder>,
        #   nil]
        #        Fluent alias for `group`.
        # @param tag [String, Symbol, Semantics::Tag, Array<String, Symbol, Semantics::Tag>, nil]
        #        Tag(s) to apply to this item (see {ItemBuilder#tag}).
        # @param tags [String, Symbol, Semantics::Tag, Array<String, Symbol, Semantics::Tag>, nil]
        #        Fluent alias for `tag`.
        # @param autoupdate [true, false, nil] Autoupdate setting (see {ItemBuilder#autoupdate})
        # @param channel [String, Core::Things::ChannelUID, nil] Channel to link the item to
        # @param expire [String] An expiration specification.
        # @param alexa [String, Symbol, Array<(String, Hash<String, Object>)>, nil]
        #   Alexa metadata (see {ItemBuilder#alexa})
        # @param ga [String, Symbol, Array<(String, Hash<String, Object>)>, nil]
        #   Google Assistant metadata (see {ItemBuilder#ga})
        # @param homekit [String, Symbol, Array<(String, Hash<String, Object>)>, nil]
        #   Homekit metadata (see {ItemBuilder#homekit})
        # @param metadata [Hash<String, Hash>] Generic metadata (see {ItemBuilder#metadata})
        # @param state [State] Initial state
        def initialize(type, name = nil, label = nil,
                       provider:,
                       dimension: nil,
                       format: nil,
                       icon: nil,
                       group: nil,
                       groups: nil,
                       tag: nil,
                       tags: nil,
                       autoupdate: nil,
                       channel: nil,
                       expire: nil,
                       alexa: nil,
                       ga: nil, # rubocop:disable Naming/MethodParameterName
                       homekit: nil,
                       metadata: nil,
                       state: nil)
          raise ArgumentError, "`name` cannot be nil" if name.nil?
          raise ArgumentError, "`dimension` can only be specified with NumberItem" if dimension && type != :number

          if provider.is_a?(GroupItemBuilder)
            name = "#{provider.name_base}#{name}"
            label = "#{provider.label_base}#{label}".strip if label
          end
          @provider = provider
          @type = type
          @name = name.to_s
          @label = label
          @dimension = dimension
          @format = format
          @icon = icon
          @groups = []
          @tags = []
          @metadata = Core::Items::Metadata::NamespaceHash.new
          @metadata.merge!(metadata) if metadata
          @autoupdate = autoupdate
          @channels = []
          @expire = nil
          self.expire(*Array(expire)) if expire
          self.alexa(alexa) if alexa
          self.ga(ga) if ga
          self.homekit(homekit) if homekit
          @state = state

          self.group(*group)
          self.group(*groups)

          self.tag(*tag)
          self.tag(*tags)

          self.channel(*channel) if channel
        end

        #
        # The item's label if one is defined, otherwise its name.
        #
        # @return [String]
        #
        def to_s
          label || name
        end

        #
        # Tag item
        #
        # @param tags [String, Symbol, Semantics::Tag]
        # @return [void]
        #
        def tag(*tags)
          unless tags.all? do |tag|
                   tag.is_a?(String) ||
                   tag.is_a?(Symbol) ||
                   (tag.is_a?(Module) && tag < Semantics::Tag)
                 end
            raise ArgumentError, "`tag` must be a subclass of Semantics::Tag, or a `String``."
          end

          tags.each do |tag|
            tag = tag.name.split("::").last if tag.is_a?(Module) && tag < Semantics::Tag
            @tags << tag.to_s
          end
        end

        #
        # Add this item to a group
        #
        # @param groups [String, GroupItemBuilder, GroupItem]
        # @return [void]
        #
        def group(*groups)
          unless groups.all? do |group|
                   group.is_a?(String) || group.is_a?(Core::Items::GroupItem) || group.is_a?(GroupItemBuilder)
                 end
            raise ArgumentError, "`group` must be a `GroupItem`, `GroupItemBuilder`, or a `String`"
          end

          @groups.concat(groups)
        end

        #
        # @!method alexa(value, config = nil)
        #   Shortcut for adding Alexa metadata
        #
        #   @see https://www.openhab.org/docs/ecosystem/alexa/
        #
        #   @param value [String, Symbol] Type of Alexa endpoint
        #   @param config [Hash, nil] Additional Alexa configuration
        #   @return [void]
        #

        #
        # @!method ga(value, config = nil)
        #   Shortcut for adding Google Assistant metadata
        #
        #   @see https://www.openhab.org/docs/ecosystem/google-assistant/
        #
        #   @param value [String, Symbol] Type of Google Assistant endpoint
        #   @param config [Hash, nil] Additional Google Assistant configuration
        #   @return [void]
        #

        #
        # @!method homekit(value, config = nil)
        #   Shortcut for adding Homekit metadata
        #
        #   @see https://www.openhab.org/addons/integrations/homekit/
        #
        #   @param value [String, Symbol] Type of Homekit accessory or characteristic
        #   @param config [Hash, nil] Additional Homekit configuration
        #   @return [void]
        #

        %i[alexa ga homekit].each do |shortcut|
          define_method(shortcut) do |value = nil, config = nil|
            value, config = value if value.is_a?(Array)
            metadata[shortcut] = [value, config]
          end
        end

        #
        # Add a channel link to this item.
        #
        # @param config [Hash] Additional configuration, such as profile
        # @return [void]
        #
        # @example
        #   items.build do
        #     date_time_item "Bedroom_Light_Updated" do
        #       channel "hue:0210:1:bulb1:color", profile: "system:timestamp-update"
        #     end
        #   end
        #
        def channel(channel, **config)
          @channels << [channel, config]
        end

        #
        # @!method expire(command: nil, state: nil)
        #
        # Configure item expiration
        #
        # @return [void]
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

          duration = duration.to_s[2..].downcase if duration.is_a?(Duration)
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
            group = group.name if group.respond_to?(:name)
            item.add_group_name(group.to_s)
          end
          tags.each do |tag|
            item.add_tag(tag)
          end
          item.metadata.merge!(metadata)
          item.metadata["autoupdate"] = autoupdate.to_s unless autoupdate.nil?
          item.metadata["expire"] = expire if expire
          item.metadata["stateDescription"] = { "pattern" => format } if format
          item.state = item.format_update(state) unless state.nil?
          item
        end

        # @return [String]
        def inspect
          s = "#<OpenHAB::Core::Items::#{inspect_type}ItemBuilder#{type_details} #{name} #{label.inspect}"
          s += " category=#{icon.inspect}" if icon
          s += " tags=#{tags.inspect}" unless tags.empty?
          s += " groups=#{groups.map { |g| g.respond_to?(:name) ? g.name : g }.inspect}" unless groups.empty?
          s += " metadata=#{metadata.to_h.inspect}" unless metadata.empty?
          "#{s}>"
        end

        private

        # @return [String]
        def inspect_type
          type.to_s.capitalize
        end

        # @return [String, nil]
        def type_details
          ":#{dimension}" if dimension
        end

        def create_item
          type = @type.to_s.gsub(/(?:^|_)[a-z]/) { |match| match[-1].upcase }
          type = "#{type}:#{dimension}" if dimension
          self.class.item_factory.create_item(type, name)
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
        # @return [Core::Things::ThingUID, Core::Things::Thing, String, nil]
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
        # @param thing [Core::Things::ThingUID, Core::Things::Thing, String, nil]
        #        A Thing to be used as the base for the channel for any contained items.
        # @param (see ItemBuilder#initialize)
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
            Core::Items::GroupItem.new(name, base_item, function)
          else
            Core::Items::GroupItem.new(name, base_item)
          end
        end

        # @!visibility private
        def add(child_item)
          @members << child_item
        end

        private

        # @return [String]
        def inspect_type
          "Group"
        end

        # @return [String, nil]
        def type_details
          r = super
          r = "#{r}:#{function}" if function
          r
        end

        def provider
          self
        end
      end
    end
  end
end
