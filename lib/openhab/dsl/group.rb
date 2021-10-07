# frozen_string_literal: true

require 'singleton'

require 'openhab/dsl/lazy_array'

module OpenHAB
  module DSL
    #
    # Provides access to OpenHAB Groups
    #
    module Groups
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
          group = Core::EntityLookup.lookup_item(name)
          group.is_a?(Items::GroupItem) ? group : nil
        end
        alias include? []
        alias key? include?

        # explicit conversion to array
        def to_a
          $ir.items.grep(org.openhab.core.items.GroupItem) # rubocop:disable Style/GlobalVars
        end
      end

      #
      # Retreive all OpenHAB groups
      #
      # @return [Set] of OpenHAB Groups
      #
      def groups
        Groups.instance
      end
    end
  end
end
