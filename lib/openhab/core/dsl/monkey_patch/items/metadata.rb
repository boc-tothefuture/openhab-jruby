# frozen_string_literal: true

require 'java'
require 'openhab/osgi'

module OpenHAB
  module Core
    module DSL
      module MonkeyPatch
        module Items
          module Metadata
            java_import org.openhab.core.items.Metadata
            java_import org.openhab.core.items.MetadataKey

            def self.get_all
              @@metadata_registry.getAll
            end
          end

          def meta
            @meta ||= NamespaceAccessor.new(name)
          end

          class NamespaceAccessor
            @registry = OpenHAB::OSGI.service('org.openhab.core.items.MetadataRegistry')

            def initialize(item_name:)
              @item_name = item_name
            end

            def [](namespace)
              Namespace.new(@registry.get(MetadataKey.new(namespace, @item_name)))
            end

            def []=(namespace_name, namespace)
              @registry.get(MetadataKey.new(namespace, @item_name))
            end
          end

          class Namespace < SimpleDelegator

          end

          module MetadataExtension
            class MetadataHash < Hash
              def initialize(item_name)
                @item_name = item_name
                super()
              end

              def [](key)
                @metadata = Metadata.get_metadata(@item_name, key.to_s)
                logger.info("META checking for #{key}")
                return nil unless @metadata
                if @metadata&.getConfiguration
                  return Hash['value' => @metadata&.getValue, 'config' => @metadata&.getConfiguration]
                end

                @metadata&.getValue
              end

              def []=(key, value)
                # todo
              end

              def each(&block)
                Metadata.get_all.each do |meta|
                  block.call(meta.uID.namespace, meta.value, meta.configuration) if meta.uID.itemName == @item_name
                end
              end
            end
          end
        end
      end
    end
  end
end
