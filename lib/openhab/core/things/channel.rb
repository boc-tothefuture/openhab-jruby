# frozen_string_literal: true

module OpenHAB
  module Core
    module Things
      java_import org.openhab.core.thing.Channel

      #
      # {Channel} is a part of a {Thing} that represents a functionality of it.
      # Therefore {Items::GenericItem Items} can be linked a to a channel.
      #
      class Channel
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
