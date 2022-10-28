# frozen_string_literal: true

require "openhab/core/lazy_array"

require_relative "generic_item"

module OpenHAB
  module Core
    module Items
      java_import org.openhab.core.items.GroupItem

      # Adds methods to core OpenHAB GroupItem type to make it more natural in
      # Ruby
      class GroupItem < GenericItem
        #
        # Class for indicating to triggers that a group trigger should be used
        #
        class GroupMembers
          include LazyArray

          # @return [GroupItem]
          attr_reader :group

          # @!visibility private
          def initialize(group_item)
            @group = group_item
          end

          # Explicit conversion to Array
          #
          # @return [Array]
          def to_a
            group.get_members.map { |i| Proxy.new(i) }
          end

          # Name of the group
          #
          # @return [String]
          def name
            group.name
          end
        end

        # Override Enumerable because we want to send them to the base item if possible
        #
        # @return [GroupMembers] `self`
        %i[command update].each do |method|
          define_method(method) do |command|
            return base_item.__send__(method, command) if base_item

            super(command)
          end
        end

        #
        # Get an Array-like object representing the members of the group
        #
        # @return [GroupMembers]
        #
        def members
          GroupMembers.new(self)
        end

        #
        # Get all members of the group recursively.
        #
        # @return [Array] An Array containing all descendants of the Group
        #
        def all_members(&block)
          super.map { |m| Proxy.new(m) }
        end

        # Delegate missing methods to `base_item` if possible
        def method_missing(method, *args, &block)
          return base_item.__send__(method, *args, &block) if base_item.respond_to?(method)

          super
        end

        # @!visibility private
        def respond_to_missing?(method, include_private = false)
          return true if base_item.respond_to?(method)

          super
        end

        # Is this ever called?
        # give the base item type a chance to format commands
        # @!visibility private
        def format_type(command)
          return super unless base_item

          base_item.format_type(command)
        end
      end
    end
  end
end
