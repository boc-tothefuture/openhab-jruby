# frozen_string_literal: true

require 'delegate'
require 'forwardable'
require 'openhab/core/entity_lookup'
require 'openhab/dsl/items/group_item'

module OpenHAB
  module DSL
    #
    # Provides access to OpenHAB Groups
    #
    module Groups
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
          group = OpenHAB::Core::EntityLookup.lookup_item(name)
          group.is_a?(OpenHAB::DSL::Items::GroupItem) ? group : nil
        end
      end

      #
      # Retreive all OpenHAB groups
      #
      # @return [Set] of OpenHAB Groups
      #
      def groups
        # rubocop: disable Style/GlobalVars
        Groups.new(OpenHAB::Core::EntityLookup.decorate_items($ir.items.grep(Java::OrgOpenhabCoreItems::GroupItem)))
        # rubocop: enable Style/GlobalVars
      end
    end
  end
end
