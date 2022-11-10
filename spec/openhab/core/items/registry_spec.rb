# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Items::Registry do
  before do
    items.build do
      dimmer_item "DimmerTest", "Test Dimmer", state: 45
      switch_item "SwitchTest", "Test Switch", state: OFF
      switch_item "SwitchTwo", "Test Switch Two", state: OFF
    end
  end

  it "can access items as an enumerable" do
    expect(items.count).to be 3
    expect(items.sort_by(&:label)).to eql [DimmerTest, SwitchTest, SwitchTwo]
  end

  it "can look up items by name" do
    expect(items["DimmerTest"]).to be DimmerTest
  end

  it "can check for existence" do
    expect(items.include?("DimmerTest")).to be true
    expect(items.include?("SimmerTest")).to be false
    expect(items["SimmerTest"]).to be_nil
  end
end
