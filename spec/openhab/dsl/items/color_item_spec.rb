# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::ColorItem do
  subject(:item) do
    items.build do
      color_item "Color", state: HSBType::BLACK
    end
  end

  it "can be updated to an HSBType" do
    item << HSBType.new(0, 100, 100)
    expect(item.state).to eq "0,100,100"
  end

  it "can be updated to an HSBType from RGB" do
    item << HSBType.from_rgb(255, 0, 0)
    expect(item.state).to eq "0,100,100"
  end

  [
    "0,100,100",
    "#FF0000",
    { r: 255, g: 0, b: 0 },
    { "r" => 255, "g" => 0, "b" => 0 },
    { red: 255, green: 0, blue: 0 },
    { "red" => 255, "green" => 0, "blue" => 0 },
    { h: 0, s: 100, b: 100 },
    { "h" => 0, "s" => 100, "b" => 100 },
    { hue: 0, saturation: 100, brightness: 100 },
    { "hue" => 0, "saturation" => 100, "brightness" => 100 }
  ].each do |command|
    it "can be updated to #{command}" do
      item << command
      expect(item.state).to eq "0,100,100"
    end
  end
end
