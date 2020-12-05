# frozen_string_literal: true

require 'java'

# rubocop:disable  Style/ClassAndModuleChildren
module Java::org.openhab.core.thing::Thing
  # rubocop:enable  Style/ClassAndModuleChildren
  def method_missing(method, *args, &block)
    # replace underscore with # to match channel names
    channel_name = "#{uid}:#{method.to_s.gsub('_', '#')}"
    channels.first { |channel| channel.uid == channel_name } || super
  end
end
