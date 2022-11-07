# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Items::GenericItem do
  before do
    items.build do
      group_item "House" do
        switch_item "LightSwitch", groups: ["NonExistent"]
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
end
