# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::Metadata do
  subject(:item) { items.build { switch_item "TestItem" } }

  it "stringifies config keys" do
    item.meta["homekit"] = {}
    item.meta["homekit"][:maxValue] = 10_000
    expect(item.meta["homekit"].to_h).to eql({ "maxValue" => 10_000 })
  end

  it "stringifies config keys when setting entire config" do
    item.meta["homekit"] = {}
    item.meta["homekit"].config = { maxValue: 10_000 }
    expect(item.meta["homekit"].to_h).to eql({ "maxValue" => 10_000 })
  end

  it "stringifies config keys when setting entire namespace" do
    item.meta["homekit"] = ["", { maxValue: 10_000 }]
    expect(item.meta["homekit"].to_h).to eql({ "maxValue" => 10_000 })
  end
end
