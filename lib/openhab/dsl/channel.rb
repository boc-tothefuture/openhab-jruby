# frozen_string_literal: true

require 'forwardable'

module OpenHAB
  module DSL
    java_import org.openhab.core.thing.Channel
    java_import org.openhab.core.thing.ChannelUID

    # Adds methods to core OpenHAB Channel to make it more natural in Ruby
    class Channel
      extend Forwardable

      delegate %i[thing item items] => :uid
    end

    # Adds methods to core OpenHAB ChannelUID to make it more natural in Ruby
    class ChannelUID
      # Return the thing this channel is associated with.
      #
      # @return [Thing] The thing associated with this channel or nil
      def thing
        things[thing_uid]
      end

      # Return the item if this channel is linked with an item. If a channel is linked to more than one item,
      # this method only returns the first item.
      #
      # @return [GenericItem] The item associated with this channel or nil
      def item
        items.first
      end

      # Returns all of the channel's linked items.
      #
      # @return [Array<GenericItem>] An array of things or an empty array
      def items
        registry = OpenHAB::Core::OSGI.service('org.openhab.core.thing.link.ItemChannelLinkRegistry')
        registry.get_linked_items(self).to_a
      end
    end
  end
end
