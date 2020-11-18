# frozen_string_literal: true

require 'java'

# It is unclear why the monkey patch below doesn't work but it creates a
# NameError: cannot load Java class org.openhab.core.thing.internal.ThingImpl
# Instead we add the method dynamically when loaded

# java_import org.openhab.core.thing.internal.ThingImpl

# puts $things.get(Java::OrgOpenhabCoreThing::ThingUID.new('astro:sun:home'))
# puts $things.get(Java::OrgOpenhabCoreThing::ThingUID.new('foo:foo:foo'))

# class Java::org::openhab::core::thing::internal::ThingImpl
##  def method_missing(method, *args, &block)
#    puts 'Method missing in Thing Impl!'
#    super
#  end
# end

# require 'jruby'
# begin
#  class Java::org::openhab::core::thing::internal::ThingImpl
#  end
# rescue Exception => e
#  JRuby.ref(e).toThrowable.getCause.printStackTrace
# end

# rubocop:disable  Style/ClassAndModuleChildren
module Java::org.openhab.core.thing::Thing
  def method_missing(method, *args, &block)
    # replace underscore with # to match channel names
    channel_name = "#{uid}:#{method.to_s.gsub('_', '#')}"
    channels.first { |channel| channel.uid == channel_name } || super
  end
end
# rubocop:enable  Style/ClassAndModuleChildren
