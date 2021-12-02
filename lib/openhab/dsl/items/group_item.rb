# frozen_string_literal: true

require_relative 'comparable_item'
require 'openhab/dsl/lazy_array'

module OpenHAB
  module DSL
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
            group.get_members.to_a
          end

          # Name of the group
          #
          # @return [String]
          def name
            group.name
          end

          alias << command
        end

        include Enumerable
        include ComparableItem

        remove_method :==

        #
        # Get an Array-like object representing the members of the group
        #
        # @return [GroupMembers]
        #
        def members
          GroupMembers.new(self)
        end

        # @deprecated
        alias items members

        #
        # Iterates through the direct members of the Group
        #
        def each(&block)
          members.each(&block)
        end

        #
        # Get all members of the group recursively. Optionally filter the items to only return
        # Groups or regular Items
        #
        # @param [Symbol] filter Either +:groups+ or +:items+
        #
        # @return [Array] An Array containing all descendants of the Group, optionally filtered
        #
        def all_members(filter = nil, &block)
          filter = nil if filter == :items
          raise ArgumentError, 'filter must be :groups or :items' unless [:groups, nil].include?(filter)

          block = ->(i) { i.is_a?(GroupItem) } if filter

          if block
            get_members(&block).to_a
          else
            get_all_members.to_a
          end
        end

        # don't want to inherit these from Enumerable, because we want to send them to the base item
        remove_method %i[ensure refresh on off up down stop move increase decrease play pause rewind fast_forward next
                         previous]

        # Delegate missing methods to +base_item+ if possible
        def method_missing(method, *args, &block)
          return base_item.__send__(method, *args, &block) if base_item.respond_to?(method)

          super
        end

        # @!visibility private
        def respond_to_missing?(method, include_private = false)
          return true if base_item.respond_to?(method)

          super
        end

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
