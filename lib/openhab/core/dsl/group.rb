# frozen_string_literal: true

require 'delegate'
require 'forwardable'
require 'openhab/core/dsl/entities'

module OpenHAB
  module Core
    module DSL
      #
      # Provides access to OpenHAB Groups
      #
      module Groups
        #
        # Indicator struct interpreted by rules to trigger based on items contained in a group
        #
        GroupItems = Struct.new(:group, keyword_init: true)

        #
        # Provide access to groups as a set
        #
        class Groups < SimpleDelegator
          #
          # Get a OpenHAB Group by name
          # @param [String] name of the group to retrieve
          #
          # @return [Set] of OpenHAB Groups
          #
          def[](name)
            group = EntityLookup.lookup_item(name)
            group.is_a? Group ? group : nil
          end
        end

        #
        # Retreive all OpenHAB groups
        #
        # @return [Set] of OpenHAB Groups
        #
        def groups
          # rubocop: disable Style/GlobalVars
          Groups.new(EntityLookup.decorate_items($ir.items.select { |item| item.is_a? GroupItem }))
          # rubocop: enable Style/GlobalVars
        end

        # Group class that provides access to OpenHAB group object and delegates other methods to
        # a set of group items
        class Group < SimpleDelegator
          extend Forwardable

          java_import org.openhab.core.items.GroupItem

          # @return [org.openhab.core.items.GroupItem] OpenHAB Java Group Item
          attr_accessor :group

          # @!macro [attach] def_delegators
          #   @!method $2
          #     Forwards to org.openhab.core.items.GroupItem
          #     @see org::openhab::core::items::GroupItem
          def_delegator :@group, :name
          def_delegator :@group, :label

          #
          # Gets members of this group that are themselves a group
          #
          # @return [Set] Set of members that are of type group
          #
          def groups
            group.members.grep(org.openhab.core.items.GroupItem)
          end

          #
          # Wraps the group in a struct, this method is intended to be called
          # as an indicator to the rule method that the user wishes to trigger
          # based on changes to group items
          #
          # @return [GroupItems] Indicator struct used by rules engine to trigger based on item changes
          #
          def items
            GroupItems.new(group: group)
          end

          #
          # @return [String] List of groups seperated by commas
          #
          def to_s
            "[#{map(&:to_s).join(',')}]"
          end
        end
      end
    end
  end
end
