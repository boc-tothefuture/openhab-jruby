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

              def initialize(metadata)
                @metadata = metadata
                super(metadata&.configuration)
              end

            end

            class NamespaceAccessor

              def initialize(item_name:)
                @item_name = item_name
              end

              def [](namespace)
                logger.trace("Namespaces (#{registry.getAll})")
                logger.trace("Namespace (#{registry.get(MetadataKey.new(namespace, @item_name))})")
                MetadataItem.new(registry.get(MetadataKey.new(namespace, @item_name)))
              end

              def []=(_namespace_name, namespace)
                registry.update(MetadataKey.new(namespace, @item_name))
              end

              private 
              def registry
                @registry ||= OpenHAB::OSGI.service('org.openhab.core.items.MetadataRegistry')
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
