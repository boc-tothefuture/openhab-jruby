# frozen_string_literal: true

module OpenHAB
  module Core
    module Things
      #
      # Contains the link between a {Thing Thing's} {Channel Channels} and {Item Items}.
      #
      module Links
        #
        # Provides {Items::Item items} linked to {Channel channels} in Ruby to openHAB.
        #
        class Provider < Core::Provider
          include org.openhab.core.thing.link.ItemChannelLinkProvider

          class << self
            #
            # The ItemChannelLink registry
            #
            # @return [org.openhab.core.thing.link.ItemChanneLinkRegistry]
            #
            def registry
              @registry ||= OSGi.service("org.openhab.core.thing.link.ItemChannelLinkRegistry")
            end

            # @!visibility private
            def link(item, channel, config = {})
              config = org.openhab.core.config.core.Configuration.new(config.transform_keys(&:to_s))
              channel = ChannelUID.new(channel) if channel.is_a?(String)
              channel = channel.uid if channel.is_a?(Channel)
              link = org.openhab.core.thing.link.ItemChannelLink.new(item.name, channel, config)

              current.add(link)
            end
          end
        end
      end
    end
  end
end
