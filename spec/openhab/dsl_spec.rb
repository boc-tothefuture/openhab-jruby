# frozen_string_literal: true

RSpec.describe OpenHAB::DSL do
  it "doesn't leak DSL methods onto other objects" do
    expect { 5.rule }.to raise_error(NoMethodError)
  end

  it "makes included methods available as class methods" do
    expect(described_class).to respond_to(:changed)
  end

  describe "#profile" do
    it "works" do
      install_addon "binding-astro", ready_markers: "openhab.xmlThingTypes"

      things.build do
        thing "astro:sun:home", "Astro Sun Data", config: { "geolocation" => "0,0" }
      end

      profile "use_a_different_state" do |_event, callback:, item:|
        callback.send_update("bar")
        expect(item).to eql MyString
        false
      end

      items.build do
        string_item "MyString",
                    channel: ["astro:sun:home:season#name", { profile: "ruby:use_a_different_state" }],
                    autoupdate: false
      end

      MyString << "foo"
      expect(MyString.state).to eq "bar"
    end
  end

  describe "#script" do
    it "creates triggerable rule" do
      triggered = false
      script id: "testscript" do
        triggered = true
      end

      trigger_rule("testscript")
      expect(triggered).to be true
    end
  end

  describe "#store_states" do
    before do
      items.build do
        switch_item "Switch1", state: OFF
        switch_item "Switch2", state: OFF
      end
    end

    it "stores and restores states" do
      states = store_states Switch1, Switch2
      Switch1.on
      expect(Switch1).to be_on
      states.restore
      expect(Switch1).to be_off
    end

    it "restores states after the block returns" do
      store_states Switch1, Switch2 do
        Switch1.on
        expect(Switch1).to be_on
      end
      expect(Switch1).to be_off
    end
  end

  describe "#unit" do
    it "converts all units and numbers to specific unit for all operations" do
      c = 23 | "°C"
      f = 70 | "°F"
      unit("°F") do
        expect(c - f < 4).to be true
        expect(c - (24 | "°C") < 4).to be true
        expect(QuantityType.new("24 °C") - c < 4).to be true
      end

      unit("°C") do
        expect(f - (20 | "°C") < 2).to be true
        expect((f - 2).format("%.1f %unit%")).to eq "19.1 °C" # rubocop:disable Style/FormatStringToken
        expect((c + f).format("%.1f %unit%")).to eq "44.1 °C" # rubocop:disable Style/FormatStringToken
        expect(f - 2 < 20).to be true
        expect(2 + c == 25).to be true
        expect(2 * c == 46).to be true
        expect((2 * (f + c) / 2) < 45).to be true
        expect([c, f, 2].min).to be 2
      end
    end

    it "supports setting multiple dimensions at once" do
      unit("°C", "ft") do
        expect(1 | "yd").to eq 3
        expect(32 | "°F").to eq 0
      end
    end

    it "can permanently set units" do
      unit!("ft")
      expect(unit(SIUnits::METRE.dimension)).to be ImperialUnits::FOOT
      unit!
      expect(unit(SIUnits::METRE.dimension)).to be_nil
    ensure
      unit!
    end
  end
end
