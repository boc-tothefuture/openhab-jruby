# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Items::Item do
  before do
    items.build do
      group_item "House" do
        switch_item "LightSwitch", group: "NonExistent"
      end
    end
  end

  describe "#groups" do
    it "doesn't include non-existent groups" do
      expect(LightSwitch.groups.map(&:name)).to eql ["House"]
    end
  end

  describe "#group_names" do
    it "works" do
      expect(LightSwitch.group_names.to_a).to match_array %w[House NonExistent]
    end
  end

  describe "#to_s" do
    it "uses the label" do
      items.build { switch_item "LightSwitch2", "My Light Switch" }
      expect(LightSwitch2.to_s).to eql "My Light Switch"
    end

    it "use the item's name if it doesn't have a label" do
      expect(LightSwitch.to_s).to eql "LightSwitch"
    end
  end

  describe "#command" do
    it "works" do
      LightSwitch.on
      expect(LightSwitch).to be_on
    end

    it "returns `self` (wrapped in a proxy)" do
      expect(LightSwitch.on).to be LightSwitch
    end
  end

  describe "#update" do
    it "works" do
      LightSwitch.update(ON)
      expect(LightSwitch).to be_on
    end

    it "returns `self` (wrapped in a proxy)" do
      expect(LightSwitch.update(ON)).to be LightSwitch
    end
  end

  describe "#undef?" do
    it "works" do
      LightSwitch.update(UNDEF)
      expect(LightSwitch).to be_undef
      LightSwitch.on
      expect(LightSwitch).not_to be_undef
    end
  end

  describe "#null?" do
    it "works" do
      LightSwitch.update(NULL)
      expect(LightSwitch).to be_null
      LightSwitch.on
      expect(LightSwitch).not_to be_null
    end
  end

  describe "#state?" do
    it "works" do
      LightSwitch.update(NULL)
      expect(LightSwitch).not_to be_state
      expect(LightSwitch.state).to be_nil
      LightSwitch.update(UNDEF)
      expect(LightSwitch).not_to be_state
      expect(LightSwitch.state).to be_nil
      LightSwitch.on
      expect(LightSwitch).to be_state
      expect(LightSwitch.state).not_to be_nil
    end
  end

  describe "#thing" do
    before do
      install_addon "binding-astro", ready_markers: "openhab.xmlThingTypes"

      things.build do
        thing "astro:sun:home", "Astro Sun Data", config: { "geolocation" => "0,0" }
        thing "astro:moon:home", "Astro Moon Data", config: { "geolocation" => "0,0" }
      end
    end

    it "returns nil for an unlinked item" do
      expect(LightSwitch.thing).to be_nil
    end

    it "returns its linked thing" do
      items.build do
        string_item "PhaseName", channel: "astro:sun:home:phase#name"
      end

      expect(PhaseName.thing).to be things["astro:sun:home"]
    end

    it "returns all linked things" do
      items.build do
        string_item "PhaseName" do
          channel "astro:sun:home:phase#name"
          channel "astro:moon:home:phase#name"
        end
      end

      expect(PhaseName.things).to match_array [things["astro:sun:home"], things["astro:moon:home"]]
    end
  end

  # See https://github.com/boc-tothefuture/openhab-jruby/issues/252
  it "can be used as a hash key" do
    hash = {
      LightSwitch => "hi"
    }
    expect(hash[LightSwitch]).to eql "hi"
    expect(hash).to have_key(LightSwitch)
    expect(hash).not_to have_key(House)
  end

  it "works with hash value" do
    hash = {
      a: LightSwitch
    }
    expect(hash).to have_value(LightSwitch)
    expect(hash).not_to have_value(House)
  end

  it "can be used in an array" do
    items.build do
      switch_item "Switch1", state: OFF
      switch_item "Switch2", state: OFF
      switch_item "Switch3", state: ON
    end

    all_items = [Switch1, Switch2, Switch3]
    expect(all_items).to be_include(Switch1)
    expect(all_items).to be_include(Switch2)
    expect(all_items).to be_include(Switch3)

    expect([Switch1, Switch3]).not_to be_include(Switch2)
  end

  it "compares items by item, not by state" do
    items.build do
      switch_item "Switch1", state: OFF
      switch_item "Switch2", state: OFF
      switch_item "Switch3", state: ON
    end

    expect(Switch1).not_to eq Switch2
    expect(Switch1).not_to eq Switch3
  end
end
