# frozen_string_literal: true

require 'delegate'
require 'forwardable'
require 'openhab/core/dsl/entities'

module OpenHAB
  module Core
    module DSL
      module Groups
        GroupItems = Struct.new(:group, keyword_init: true)

        class Groups < SimpleDelegator
          def[](name)
            group = EntityLookup.lookup_item(name)
            (group.is_a? Group) ? group : nil
          end
        end

        def groups
          Groups.new(EntityLookup.decorate_items($ir.items.select { |item| item.is_a? GroupItem }))
        end

        # Group class that provides access to OpenHAB group object and delegates other methods to
        # a set of group items
        class Group < SimpleDelegator
          extend Forwardable

          java_import org.openhab.core.items.GroupItem
          attr_accessor :group

          def_delegator :@group, :name
          def_delegator :@group, :label

          def groups
            group.members.grep(org.openhab.core.items.GroupItem)
          end

          def items
            GroupItems.new(group: group)
          end

          def to_s
            "[#{map(&:to_s).join(',')}]"
          end
        end
      end
    end
  end
end
