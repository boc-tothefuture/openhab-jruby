# frozen_string_literal: true

require "forwardable"

module OpenHAB
  module Core
    module Things
      java_import org.openhab.core.thing.Channel

      #
      # {Channel} is a part of a {Thing} that represents a functionality of it.
      # Therefore {Item Items} can be linked a to a channel.
      #
      # @!attribute [r] item
      #   (see ChannelUID#item)
      #
      # @!attribute [r] items
      #   (see ChannelUID#items)
      #
      # @!attribute [r] thing
      #   (see ChannelUID#thing)
      #
      # @!attribute [r] uid
      #   @return [ChannelUID]
      #
      class Channel
        extend Forwardable

        delegate %i[item items thing] => :uid

        # @return [String]
        def inspect
          r = "#<OpenHAB::Core::Things::Channel #{uid}"
          r += " #{label.inspect}" if label
          r += " auto_update_policy=#{auto_update_policy}" if auto_update_policy
          r += " configuration=#{configuration.properties.to_h}" unless configuration.properties.empty?
          r += " properties=#{properties.to_h}" unless properties.empty?
          "#{r}>"
        end

        # @return [String]
        def to_s
          uid.to_s
        end
      end
    end
  end
end
