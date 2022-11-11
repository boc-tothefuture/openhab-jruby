# frozen_string_literal: true

module OpenHAB
  module RSpec
    module Mocks
      class MetadataProvider
        org.openhab.core.common.registry.Identifiable
        include org.openhab.core.items.ManagedMetadataProvider

        def initialize(parent)
          @metadata = {}
          @listeners = []
          @parent = parent
          @removed_from_parent = []
        end

        def addProviderChangeListener(listener) # rubocop:disable Naming/MethodName required by java interface
          @listeners << listener
        end

        def removeProviderChangeListener(listener) # rubocop:disable Naming/MethodName required by java interface
          old = @listeners.delete(listener)
          return unless old

          @listeners.each { |l| l.removed(self, old) }
        end

        def add(metadata)
          @metadata[metadata.uid] = metadata
          @listeners.each { |l| l.added(self, metadata) }
        end

        def update(metadata)
          old_element = @metadata[metadata.uid]
          raise ArgumentError if old_element.nil?

          @metadata[metadata.uid] = metadata
          @listeners.each { |l| l.updated(self, old_element, metadata) }
          metadata
        end

        def remove(key)
          m = @parent.remove(key)
          @removed_from_parent << m if m
          m = @metadata.delete(key)
          @listeners.each { |l| l.removed(self, m) } if m
          m
        end

        def restore_parent
          @removed_from_parent.each do |m|
            @parent.add(m)
          end
        end

        def get(key)
          @metadata[key]
        end

        def getAll # rubocop:disable Naming/MethodName required by java interface
          @metadata.values
        end

        def removeItemMetadata(item_name) # rubocop:disable Naming/MethodName required by java interface
          @metadata.delete_if do |k, v|
            next unless k.item_name == item_name

            @listeners.each { |l| l.removed(self, v) }
            true
          end
        end
      end
    end
  end
end
