# frozen_string_literal: true

require "method_source"

RSpec.describe OpenHAB::DSL::Rules::Triggers::Channel do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
  before do
    install_addon "binding-astro"
    things.build { thing "astro:sun:home", config: { "geolocation" => "0,0" } }
  end

  def self.test_channel_trigger(channel = nil, event: "", &block)
    description = "supports channel trigger "
    description += "on channel #{channel} " if channel
    description += "for event #{event} " unless event.empty?
    description += "with args #{block.source.sub(/.*(?:{|do)\s+\[(.*)\]\s+(?:}|end)/, '\\1')}"

    channel ||= "astro:sun:home:rise#event"
    it description, caller: caller do
      args = instance_exec(&block)
      triggered = false
      trigger = nil
      rule "Execute rule when channel is triggered" do
        channel(*args)
        run do |e|
          triggered = true
          trigger = e.event
        end
      end
      trigger_channel(channel, event)
      expect(triggered).to be true
      expect(trigger).to eql event
    end
  end

  test_channel_trigger { ["astro:sun:home:rise#event"] }
  test_channel_trigger { ["rise#event", { thing: "astro:sun:home" }] }
  test_channel_trigger { ["rise#event", { thing: things["astro:sun:home"] }] }
  test_channel_trigger { ["rise#event", { thing: things["astro:sun:home"].uid }] }
  test_channel_trigger { ["rise#event", { thing: [things["astro:sun:home"]] }] }
  test_channel_trigger { ["rise#event", { thing: [things["astro:sun:home"].uid] }] }
  test_channel_trigger { [things["astro:sun:home"].channels["rise#event"]] }
  test_channel_trigger { [things["astro:sun:home"].channels["rise#event"].uid] }
  test_channel_trigger { [[things["astro:sun:home"].channels["rise#event"]]] }
  test_channel_trigger { [[things["astro:sun:home"].channels["rise#event"].uid]] }

  test_channel_trigger(event: "START") { ["astro:sun:home:rise#event"] }

  test_channel_trigger("astro:sun:home:rise#event", event: "START") do
    [["rise#event", "set#event"], { thing: "astro:sun:home", triggered: %w[START STOP] }]
  end
  test_channel_trigger("astro:sun:home:set#event", event: "START") do
    [["rise#event", "set#event"], { thing: "astro:sun:home", triggered: %w[START STOP] }]
  end
  test_channel_trigger("astro:sun:home:rise#event", event: "STOP") do
    [["rise#event", "set#event"], { thing: "astro:sun:home", triggered: %w[START STOP] }]
  end
  test_channel_trigger("astro:sun:home:set#event", event: "STOP") do
    [["rise#event", "set#event"], { thing: "astro:sun:home", triggered: %w[START STOP] }]
  end
end
