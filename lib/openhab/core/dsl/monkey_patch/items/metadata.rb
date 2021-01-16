# frozen_string_literal: true

require 'java'
require 'delegate'
require 'pp'
require 'forwardable'
require 'openhab/osgi'
require 'openhab/core/log'

module OpenHAB
  module Core
    module DSL
      module MonkeyPatch
        module Items
          module Metadata
            include Logging

            java_import org.openhab.core.items.Metadata
            java_import org.openhab.core.items.MetadataKey

            class MetadataItem < SimpleDelegator
              extend Forwardable

              def_delegator :@metadata, :value

              def initialize(metadata: nil, key: nil, value: nil, config: nil)
                @metadata = metadata || Metadata.new(key || MetadataKey.new('', ''), value, config)
                super(@metadata&.configuration)
              end

              def []=(key, value)
                configuration = {}.merge(@metadata&.configuration || {}).merge({ key => value })
                metadata = Metadata.new(@metadata&.uID, @metadata&.value, configuration)
                NamespaceAccessor.registry.update(metadata) if @metadata&.uID
              end

              def delete(key)
                configuration = {}.merge(@metadata&.configuration || {})
                configuration.delete(key)
                metadata = Metadata.new(@metadata&.uID, @metadata&.value, configuration)
                NamespaceAccessor.registry.update(metadata) if @metadata&.uID
              end

              def value=(value)
                raise ArgumentError, 'Value must be a string' unless value.is_a? String

                metadata = Metadata.new(@metadata&.uID, value, @metadata&.configuration)
                NamespaceAccessor.registry.update(metadata) if @metadata&.uID
              end

              def config=(config)
                raise ArgumentError, 'Configuration must be a hash' unless config.is_a? Hash

                metadata = Metadata.new(@metadata&.uID, @metadata&.value, config)
                NamespaceAccessor.registry.update(metadata) if @metadata&.uID
              end
              alias configuration= config=
            end

            class NamespaceAccessor
              include Enumerable

              def initialize(item_name:)
                @item_name = item_name
              end

              def [](namespace)
                logger.trace("Namespaces (#{NamespaceAccessor.registry.getAll})")
                logger.trace("Namespace (#{NamespaceAccessor.registry.get(MetadataKey.new(namespace, @item_name))})")
                metadata = NamespaceAccessor.registry.get(MetadataKey.new(namespace, @item_name))
                MetadataItem.new(metadata: metadata) if metadata
              end

              def []=(namespace, value)
                case value
                when MetadataItem
                  meta_value = value.value
                  configuration = value.__getobj__
                when Metadata
                  meta_value = value.value
                  configuration = value.configuration
                when Hash
                  meta_value = nil
                  configuration = value
                when Array
                  meta_value = value[0]
                  configuration = value[1]
                else
                  meta_value = value
                  configuration = nil
                end

                key = MetadataKey.new(namespace, @item_name)
                metadata = Metadata.new(key, meta_value, configuration)
                if NamespaceAccessor.registry.get(key)
                  NamespaceAccessor.registry.update(metadata)
                else
                  NamespaceAccessor.registry.add(metadata)
                end
              end

              def each(&block)
                NamespaceAccessor.registry.getAll.each do |meta|
                  if meta.uID.itemName == @item_name
                    block.call(meta.uID.namespace, meta.value,
                               meta.configuration)
                  end
                end
              end

              def clear
                NamespaceAccessor.registry.removeItemMetadata @item_name
              end

              def delete(namespace)
                NamespaceAccessor.registry.remove(MetadataKey.new(namespace, @item_name))
              end

              def has_key?(namespace)
                !NamespaceAccessor.registry.get(MetadataKey.new(namespace, @item_name)).nil?
              end

              alias key? has_key?
              alias include? has_key?
              alias namespace? has_key?

              def self.registry
                @@registry ||= OpenHAB::OSGI.service('org.openhab.core.items.MetadataRegistry')
              end
            end

            def meta
              @meta ||= NamespaceAccessor.new(item_name: name)
            end
            alias metadata meta
          end
        end
      end
    end
  end
end
