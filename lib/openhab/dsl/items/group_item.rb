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

          # Send a command to each member of the group
          #
          # @return [GroupMembers] +self+
          def command(command)
            each { |item| item << command }
          end
          alias << command

          # @!method refresh
          #   Send the +REFRESH+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method on
          #   Send the +ON+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method off
          #   Send the +OFF+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method up
          #   Send the +UP+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method down
          #   Send the +DOWN+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method stop
          #   Send the +STOP+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method move
          #   Send the +MOVE+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method increase
          #   Send the +INCREASE+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method desrease
          #   Send the +DECREASE+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method play
          #   Send the +PLAY+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method pause
          #   Send the +PAUSE+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method rewind
          #   Send the +REWIND+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method fast_forward
          #   Send the +FASTFORWARD+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method next
          #   Send the +NEXT+ command to each member of the group
          #   @return [GroupMembers] +self+

          # @!method previous
          #   Send the +PREVIOUS+ command to each member of the group
          #   @return [GroupMembers] +self+
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
