# frozen_string_literal: true

require 'delegate'
require 'forwardable'
require 'java'
require 'openhab/dsl/items/item_command'
require 'openhab/dsl/items/item_delegate'
require 'openhab/core/entity_lookup'

module OpenHAB
  module DSL
    module Items
      #
      # Class for indicating to triggers that a group trigger should be used
      #
      class GroupMembers < SimpleDelegator
        attr_reader :group

        #
        # Create a new GroupMembers instance from a GroupItem
        #
        # @param [GroupItem] group_item GroupItem to use as trigger
        #
        def initialize(group_item)
          @group = group_item
          super(OpenHAB::Core::EntityLookup.decorate_items(@group.members.to_a))
        end
      end

      #
      # Delegator to OpenHAB Group Item
      #
      class GroupItem
        extend OpenHAB::DSL::Items::ItemCommand
        extend OpenHAB::DSL::Items::ItemDelegate
        include Enumerable
        include Comparable

        def_item_delegator :@group_item

        #
        # @return [Hash] A hash of lambdas with default filters for `all_members`
        #
        DEFAULT_FILTERS = {
          groups: ->(item) { item.is_a?(Java::OrgOpenhabCoreItems::GroupItem) },
          all: -> { true }
        }.freeze

        private_constant :DEFAULT_FILTERS

        #
        # Create a new GroupItem
        #
        # @param [Java::Org::openhab::core::items::GroupItem] group_item OpenHAB GroupItem to delegate to
        #
        def initialize(group_item)
          @group_item = group_item

          item_missing_delegate { @group_item }
          item_missing_delegate { OpenHAB::Core::EntityLookup.decorate_item(base_item) }
        end

        #
        # Create a GroupMembers object for use in triggers
        #
        # @return [GroupMembers] A GroupMembers object
        #
        def members
          GroupMembers.new(@group_item)
        end

        #
        # Iterates through the direct members of the Group
        #
        def each(&block)
          OpenHAB::Core::EntityLookup.decorate_items(@group_item.members.to_a).each(&block)
        end

        #
        # Get all members of the group recursively. Optionally filter the items to only return
        # Groups or regular Items
        #
        # @param [Symbol] filter Either :groups or :items
        #
        # @return [Array] An Array containing all descendants of the Group, optionally filtered
        #
        def all_members(filter = nil, &block)
          predicate = DEFAULT_FILTERS[filter] || block

          return OpenHAB::Core::EntityLookup.decorate_items(@group_item.all_members.to_a) unless predicate

          OpenHAB::Core::EntityLookup.decorate_items(@group_item.get_members(&predicate).to_a)
        end

        #
        # Test for equality
        #
        # @param [Object] other Other object to compare against
        #
        # @return [Boolean] true if self and other can be considered equal, false otherwise
        #
        def ==(other)
          if other.respond_to?(:java_class) && accepted_data_types.include?(other.java_class)
            get_state_as(other.class) == other
          elsif other.respond_to?(:state)
            base_item ? OpenHAB::Core::EntityLookup.decorate_item(base_item) == other.state : self == other.state
          else
            super
          end
        end

        #
        # Compare GroupItem to supplied object
        #
        # @param [Object] other object to compare to
        #
        # @return [Integer] -1,0,1 or nil depending on value supplied,
        #   nil comparison to supplied object is not possible.
        #
        def <=>(other)
          if base_item
            OpenHAB::Core::EntityLookup.decorate_item(base_item) <=> other
          elsif state?
            -(other <=> state)
          else
            super
          end
        end
      end
    end
  end
end
