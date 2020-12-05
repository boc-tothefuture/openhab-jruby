# frozen_string_literal: true

require 'delegate'

module OpenHAB
  module Core
    module DSL
      module Groups
        GroupItems = Struct.new(:group, keyword_init: true)

        class Groups < SimpleDelegator
          def[](name)
            group = $ir.getItem(name)
            (group.is_a? GroupItem) ? group : nil
          end
        end

        def groups
          Groups.new($ir.items.select { |item| item.is_a? GroupItem })
        end

        # Group class that provides access to OpenHAB group object and delegates other methods to
        # an array of group items
        class Group < SimpleDelegator
          java_import org.openhab.core.items.GroupItem
          attr_accessor :group

          def groups
            group.members.grep(org.openhab.core.items.GroupItem)
          end

          def items
            GroupItems.new(group: group)
          end
        end
      end
    end
  end
end
