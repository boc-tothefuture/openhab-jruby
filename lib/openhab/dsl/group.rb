# frozen_string_literal: true

require "singleton"

require "openhab/core/entity_lookup"
require "openhab/dsl/lazy_array"

module OpenHAB
  module DSL
    #
    # Provides access to OpenHAB Groups
    #
    module Groups
      module_function

      #
      # Retrieve all OpenHAB groups
      #
      # @return [Set] of OpenHAB Groups
      #
      def groups
        OpenHAB::DSL::Support::Groups.instance
      end
    end

    module Support
      #
      # Provide access to groups as a set
      #
      class Groups
        include LazyArray
        include Singleton

        #
        # Get a OpenHAB Group by name
        # @param [String] name of the group to retrieve
        #
        # @return [Set] of OpenHAB Groups
        #
        def [](name)
          group = OpenHAB::Core::EntityLookup.lookup_item(name)
          group.is_a?(OpenHAB::DSL::Items::GroupItem) ? group : nil
        end
        alias_method :include?, :[]
        alias_method :key?, :include?

        # explicit conversion to array
        def to_a
          $ir.items.grep(org.openhab.core.items.GroupItem)
        end
      end
    end
  end
end
