# frozen_string_literal: true

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB items
      #
      module Items
        java_import Java::OrgOpenhabCoreItems::GroupItem

        #
        # Monkey patch Group Item
        #
        class GroupItem
          #
          # Get all items in a group
          #
          # @return [Array] Array of items in the group
          #
          def items
            to_a
          end

          #
          # Get all items in the group as an Array
          #
          # @return [Array] All items in the group
          #
          def to_a
            all_members.each_with_object([]) { |item, arr| arr << item }
          end
        end
      end
    end
  end
end
