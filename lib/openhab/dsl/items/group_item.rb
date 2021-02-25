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


    class GroupMembers < SimpleDelegator

      attr_reader :group

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

        def_item_delegator :@group_item

        #
        # Indicator struct interpreted by rules to trigger based on items contained in a group
        #
        GroupItems = Struct.new(:group, keyword_init: true)

        #
        # Create a new GroupItem
        #
        # @param [Java::Org::openhab::core::items::GroupItem] group_item OpenHAB GroupItem to delegate to
        #
        def initialize(group_item)
          @group_item = group_item

          item_missing_delegate { @group_item }
          add_state_methods
          add_command_methods
        end


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
        # Get all members of the group recursively
        #
        # @return [Array] An Array containing all descendants of the Group
        def all_members
          OpenHAB::Core::EntityLookup.decorate_items(@group_item.all_members.to_a)
        end

        #
        # Wraps the group in a struct, this method is intended to be called
        # as an indicator to the rule method that the user wishes to trigger
        # based on changes to group items
        #
        # @return [GroupItems] Indicator struct used by rules engine to trigger based on item changes
        #
        def items
          GroupItems.new(group: self)
        end

        private

        #
        # Add state methods for the Groups base item type
        #
        def add_state_methods
          data_enums = get_accepted_data_types.select(&:is_enum)
          singleton_class.class_eval do
            data_enums.each { |type| item_state(type.ruby_class) }
          end
        end

        #
        # Add command methods for the Groups base item type
        #
        def add_command_methods
          command_enums = get_accepted_command_types.select(&:is_enum)
          singleton_class.class_eval do
            command_enums.each { |type| item_command(type.ruby_class) }
          end
        end
      end
    end
  end
end
