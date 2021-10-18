# frozen_string_literal: true

require 'delegate'
require 'pp'
require 'forwardable'
require 'openhab/core/osgi'
require 'openhab/log/logger'

module OpenHAB
  module DSL
    module Items
      #
      # Metadata extension for Items
      #
      module Metadata
        include OpenHAB::Log

        java_import Java::OrgOpenhabCoreItems::Metadata
        java_import Java::OrgOpenhabCoreItems::MetadataKey

        #
        # Provide the interface to access namespace's value and configuration
        #
        class MetadataItem < SimpleDelegator
          extend Forwardable

          def_delegator :@metadata, :value

          def initialize(metadata: nil, key: nil, value: nil, config: nil)
            @metadata = metadata || Metadata.new(key || MetadataKey.new('', ''), value&.to_s, config)
            super(to_ruby(@metadata&.configuration))
          end

          #
          # Updates the metadata configuration associated with the key
          #
          def []=(key, value)
            configuration = {}.merge(@metadata&.configuration || {}).merge({ key => value })
            metadata = Metadata.new(@metadata&.uID, @metadata&.value, configuration)
            NamespaceAccessor.registry.update(metadata) if @metadata&.uID
          end

          #
          # Delete the configuration with the given key
          #
          # @return [Java::Org::openhab::core::items::Metadata] the old metadata
          #
          def delete(key)
            configuration = {}.merge(@metadata&.configuration || {})
            configuration.delete(key)
            metadata = Metadata.new(@metadata&.uID, @metadata&.value, configuration)
            NamespaceAccessor.registry.update(metadata) if @metadata&.uID
          end

          #
          # Set the metadata value
          #
          # @return [Java::Org::openhab::core::items::Metadata] the old metadata
          #
          def value=(value)
            metadata = Metadata.new(@metadata&.uID, value&.to_s, @metadata&.configuration)
            NamespaceAccessor.registry.update(metadata) if @metadata&.uID
          end

          #
          # Set the entire configuration to a hash
          #
          # @return [Java::Org::openhab::core::items::Metadata] the old metadata
          #
          def config=(config)
            raise ArgumentError, 'Configuration must be a hash' unless config.is_a? Hash

            metadata = Metadata.new(@metadata&.uID, @metadata&.value, config)
            NamespaceAccessor.registry.update(metadata) if @metadata&.uID
          end
          alias configuration= config=

          #
          # Convert the metadata to an array
          #
          # @return [Array[2]] An array of [value, configuration]
          #
          def to_a
            [@metadata&.value, @metadata&.configuration || {}]
          end

          private

          #
          # Recursively convert the supplied Hash object into a Ruby Hash and recreate the keys and values
          #
          # @param [Hash] Hash to convert
          #
          # @return [Hash] The converted hash
          #
          def to_ruby_hash(hash)
            return unless hash.respond_to? :each_with_object

            hash.each_with_object({}) { |(key, value), ruby_hash| ruby_hash[to_ruby(key)] = to_ruby(value) }
          end

          #
          # Recursively convert the supplied array to a Ruby array and recreate all String values
          #
          # @param [Object] array to convert
          #
          # @return [Array] The converted array
          #
          def to_ruby_array(array)
            return unless array.respond_to? :each_with_object

            array.each_with_object([]) { |value, ruby_array| ruby_array << to_ruby(value) }
          end

          # Convert the given object to Ruby equivalent
          def to_ruby(value)
            case value
            when Hash, Java::JavaUtil::Map then to_ruby_hash(value)
            when Array, Java::JavaUtil::List then to_ruby_array(value)
            when String then String.new(value)
            else value
            end
          end
        end

        #
        # Provide the interface to access item metadata
        #
        class NamespaceAccessor
          include Enumerable

          def initialize(item_name:)
            @item_name = item_name
          end

          #
          # Return the metadata namespace
          #
          # @return [OpenHAB::DSL::Items::MetadataItem], or nil if the namespace doesn't exist
          #
          def [](namespace)
            logger.trace("Getting metadata for item: #{@item_name}, namespace '#{namespace}'")
            metadata = NamespaceAccessor.registry.get(MetadataKey.new(namespace, @item_name))
            MetadataItem.new(metadata: metadata) if metadata
          end

          #
          # Set the metadata namespace. If the namespace does not exist, it will be created
          #
          # @param value [Object] The assigned value can be a OpenHAB::DSL::Items::MetadataItem,
          # Java::Org::openhab::core::items::Metadata, Array[2] of [value, configuration],
          # A String to set the value and clear the configuration,
          # or a Hash to set the configuration and set the value to nil
          #
          # @return [OpenHAB::DSL::Items::MetadataItem]
          #
          def []=(namespace, value)
            meta_value, configuration = update_from_value(value)

            key = MetadataKey.new(namespace, @item_name)
            metadata = Metadata.new(key, meta_value&.to_s, configuration)
            # registry.get can be omitted, but registry.update will log a warning for nonexistent metadata
            if NamespaceAccessor.registry.get(key)
              NamespaceAccessor.registry.update(metadata)
            else
              NamespaceAccessor.registry.add(metadata)
            end
          end

          #
          # Implements Hash#dig-like functionaity to metadata
          #
          # @param [String] key The first key
          # @param [Array<String, Symbol>] keys More keys to dig deeper
          #
          # @return [OpenHAB::DSL::Items::MetadataItem], or nil if the namespace doesn't exist
          #
          def dig(key, *keys)
            keys.empty? ? self[key]&.value : self[key]&.dig(*keys)
          end

          #
          # Enumerates through all the namespaces
          #
          def each
            return unless block_given?

            NamespaceAccessor.registry.getAll.each do |meta|
              yield meta.uID.namespace, meta.value, meta.configuration if meta.uID.itemName == @item_name
            end
          end

          #
          # Remove all the namespaces
          #
          def clear
            NamespaceAccessor.registry.removeItemMetadata @item_name
          end

          #
          # Delete a specific namespace
          #
          # @param namespace [String] The namespace to delete
          #
          def delete(namespace)
            NamespaceAccessor.registry.remove(MetadataKey.new(namespace, @item_name))
          end

          alias delete_all clear

          #
          # @return [Boolean] True if the given namespace exists, false otherwise
          #
          def key?(namespace)
            !NamespaceAccessor.registry.get(MetadataKey.new(namespace, @item_name)).nil?
          end

          alias has_key? key?
          alias include? key?

          #
          # Merge the given hash with the current metadata. Existing namespace that matches the name
          # of the new namespace will be overwritten. Others will be added.
          #
          def merge!(*others)
            return self if others.empty?

            others.each do |other|
              case other
              when Hash then merge_hash!(other)
              when self.class then merge_metadata!(other)
              else raise ArgumentError, "merge only supports Hash, or another item's metadata"
              end
            end
            self
          end

          #
          # @return [String] the string representation of all the namespaces with their value and config
          #
          def to_s
            namespaces = []
            each { |ns, value, config| namespaces << "\"#{ns}\"=>[\"#{value}\",#{config}]" }
            "{#{namespaces.join(',')}}"
          end

          #
          # @return [Java::org::openhab::core::items::MetadataRegistry]
          #
          def self.registry
            @registry ||= OpenHAB::Core::OSGI.service('org.openhab.core.items.MetadataRegistry')
          end

          private

          #
          # perform an updated based on the supplied value
          #
          # @param [MetadataItem,Metadata,Array,Hash] value to perform update from
          #
          # @return [Array<Object,Hash>] Array containing the value and configuration based on the
          #   the supplied object
          #
          def update_from_value(value)
            case value
            when MetadataItem then [value.value, value.__getobj__]
            when Metadata then [value.value, value.configuration]
            when Array
              raise ArgumentError, 'Array must contain 2 elements: value, config' if value.length != 2

              value
            when Hash then [nil, value]
            else [value, nil]
            end
          end

          #
          # Merge the metadata from the supplied other metadata object
          #
          # @param [Hash] other metadata object to merge
          # @yield [key, current_metadata, new_meta] to process merge
          #
          #
          def merge_metadata!(other)
            other.each do |key, new_value, new_config|
              new_meta = new_value, new_config
              if block_given?
                current_meta = self[key]&.to_a
                new_meta = yield key, current_meta, new_meta unless current_meta.nil?
              end
              self[key] = new_meta
            end
          end

          #
          # Merge a hash into the metadata
          #
          # @param [Hash] other to merge into metadata
          # @yield [key, current_metadata, new_meta] to process merge
          #
          #
          def merge_hash!(other)
            other.each do |key, new_meta|
              if block_given?
                current_meta = self[key]&.to_a
                new_meta = yield key, current_meta, new_meta unless current_meta.nil?
              end
              self[key] = new_meta
            end
          end
        end

        #
        # Accessor to the item's metadata
        #
        # @return [NamespaceAccessor] an Enumerable object to access item's namespaces
        #
        def meta
          @meta ||= NamespaceAccessor.new(item_name: name)
        end
        alias metadata meta
      end
    end
  end
end
