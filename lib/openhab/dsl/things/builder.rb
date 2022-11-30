# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Contains extensions to simplify working with {Core::Things::Thing Thing}s.
    #
    module Things
      # A thing builder allows you to dynamically create OpenHAB thing at runtime.
      # This can be useful either to create things as soon as the script loads,
      # or even later based on a rule executing.
      #
      # @example
      #   things.build do
      #     thing "astro:sun:home", "Astro Sun Data", config: { "geolocation" => "0,0" }
      #   end
      class Builder
        # @return [org.openhab.core.things.ManagedThingProvider]
        attr_reader :provider

        def initialize(provider)
          @provider = Core::Things::Provider.current(provider)
        end

        # Create a new Bridge
        # @see BridgeBuilder#initialize
        def bridge(*args, **kwargs, &block)
          build(BridgeBuilder, *args, **kwargs, &block)
        end

        # Create a new Thing
        # @see ThingBuilder#initialize
        def thing(*args, **kwargs, &block)
          build(ThingBuilder, *args, **kwargs, &block)
        end

        private

        def build(klass, *args, **kwargs, &block)
          builder = klass.new(*args, **kwargs)
          builder.instance_eval(&block) if block
          thing = provider.add(builder.build)
          thing = Core::Things::Proxy.new(thing)
          thing.enable(enabled: builder.enabled) unless builder.enabled.nil?
          thing
        end
      end

      # The ThingBuilder DSL allows you to customize a thing
      class ThingBuilder
        # The label for this thing
        # @return [String, nil]
        attr_accessor :label
        # The location for this thing
        # @return [String, nil]
        attr_accessor :location
        # The id for this thing
        # @return [Core::Things::ThingUID]
        attr_reader :uid
        # The type of this thing
        # @return [ThingTypeUID]
        attr_reader :thing_type_uid
        # The bridge of this thing
        # @return [Core::Things::ThingUID, nil]
        attr_reader :bridge_uid
        # The config for this thing
        # @return [Hash, nil]
        attr_reader :config
        # If the thing should be enabled after it is created
        # @return [true, false, nil]
        attr_reader :enabled
        # Explicitly configured channels on this thing
        # @return [Array<ChannelBuilder>]
        attr_reader :channels

        class << self
          # @!visibility private
          def thing_type_registry
            @thing_type_registry ||= OSGi.service("org.openhab.core.thing.type.ThingTypeRegistry")
          end

          # @!visibility private
          def config_description_registry
            @config_description_registry ||=
              OSGi.service("org.openhab.core.config.core.ConfigDescriptionRegistry")
          end

          # @!visibility private
          def thing_factory_helper
            @thing_factory_helper ||= begin
              # this is an internal class, so OSGi doesn't put it on the main class path,
              # so we have to go find it ourselves manually
              bundle = org.osgi.framework.FrameworkUtil.get_bundle(org.openhab.core.thing.Thing)
              bundle.load_class("org.openhab.core.thing.internal.ThingFactoryHelper").ruby_class
            end
          end
        end

        def initialize(uid, label = nil, binding: nil, type: nil, bridge: nil, location: nil, config: {}, enabled: nil)
          @channels = []
          uid = uid.to_s
          uid_segments = uid.split(org.openhab.core.common.AbstractUID::SEPARATOR)
          @bridge_uid = nil
          bridge = bridge.uid if bridge.is_a?(org.openhab.core.thing.Bridge) || bridge.is_a?(BridgeBuilder)
          bridge = bridge&.to_s
          bridge_segments = bridge&.split(org.openhab.core.common.AbstractUID::SEPARATOR) || []
          type = type&.to_s

          # infer missing components
          type ||= uid_segments[0] if uid_segments.length == 2
          type ||= uid_segments[1] if uid_segments.length > 2
          binding ||= uid_segments[0] if uid_segments.length > 2
          binding ||= bridge_segments[0] if bridge_segments && bridge_segments.length > 2

          if bridge
            bridge_segments.unshift(binding) if bridge_segments.length < 3
            @bridge_uid = org.openhab.core.thing.ThingUID.new(*bridge_segments)
          end

          @uid = org.openhab.core.thing.ThingUID.new(*[binding, type, @bridge_uid&.id,
                                                       uid_segments.last].compact)
          @thing_type_uid = org.openhab.core.thing.ThingTypeUID.new(*@uid.all_segments[0..1])
          @label = label
          @location = location
          @location = location.label if location.is_a?(GenericItem)
          @config = config.transform_keys(&:to_s)
          @enabled = enabled
        end

        # Add an explicitly configured channel to this item
        # @see ChannelBuilder#initialize
        def channel(*args, **kwargs, &block)
          channel = ChannelBuilder.new(*args, thing: self, **kwargs)
          channel.instance_eval(&block) if block
          @channels << channel.build
        end

        # @!visibility private
        def build
          configuration = org.openhab.core.config.core.Configuration.new(config)
          if thing_type
            self.class.thing_factory_helper.apply_default_configuration(
              configuration, thing_type,
              self.class.config_description_registry
            )
          end
          builder = org.openhab.core.thing.binding.builder.ThingBuilder
                       .create(thing_type_uid, uid)
                       .with_label(label)
                       .with_configuration(configuration)
                       .with_bridge(bridge_uid)
                       .with_channels(channels)

          if thing_type
            # can't use with_channels, or it will wipe out custom channels from above
            self.class.thing_factory_helper.create_channels(thing_type, uid,
                                                            self.class.config_description_registry).each do |channel|
              builder.with_channel(channel)
            end
            builder.with_properties(thing_type.properties)
          end

          thing = builder.build
          Core::Things.manager.set_enabled(uid, enabled) unless enabled.nil?
          thing
        end

        private

        def thing_type
          @thing_type ||= self.class.thing_type_registry.get_thing_type(thing_type_uid)
        end
      end

      # The BridgeBuilder DSL allows you to customize a thing
      class BridgeBuilder < ThingBuilder
        # Create a new Bridge with this Bridge as its Bridge
        # @see BridgeBuilder#initialize
        def bridge(*args, **kwargs, &block)
          super(*args, bridge: self, **kwargs, &block)
        end

        # Create a new Thing with this Bridge as its Bridge
        # @see ThingBuilder#initialize
        def thing(*args, **kwargs, &block)
          super(*args, bridge: self, **kwargs, &block)
        end
      end

      # The ChannelBuilder DSL allows you to customize a channel
      class ChannelBuilder
        attr_accessor :label
        attr_reader :uid, :parameters, :type

        def initialize(uid, type, label = nil, thing:, group: nil, **parameters)
          @thing = thing

          uid = uid.to_s
          uid_segments = uid.split(org.openhab.core.common.AbstractUID::SEPARATOR)
          group_segments = uid_segments.last.split(org.openhab.core.thing.ChannelUID::CHANNEL_GROUP_SEPARATOR)
          if group
            if group_segments.length == 2
              group_segments[0] = group
            else
              group_segments.unshift(group)
            end
            uid_segments[-1] = group_segments.join(org.openhab.core.thing.ChannelUID::CHANNEL_GROUP_SEPARATOR)
          end
          @uid = org.openhab.core.thing.ChannelUID.new(thing.uid, uid_segments.last)
          unless type.is_a?(org.openhab.core.thing.type.ChannelTypeUID)
            type = org.openhab.core.thing.type.ChannelTypeUID.new(thing.uid.binding_id, type)
          end
          @type = type
          @label = label
          @parameters = parameters.transform_keys(&:to_s)
        end

        # @!visibility private
        def build
          org.openhab.core.thing.binding.builder.ChannelBuilder.create(uid)
             .with_kind(kind)
             .with_type(type)
             .with_configuration(org.openhab.core.config.core.Configuration.new(parameters))
             .build
        end

        private

        def kind
          if @type == :trigger
            org.openhab.core.thing.type.ChannelKind::TRIGGER
          else
            org.openhab.core.thing.type.ChannelKind::STATE
          end
        end
      end
    end
  end
end
