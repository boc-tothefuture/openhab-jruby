# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Rules::Terse do
  it "works" do
    items.build { switch_item "TestSwitch" }
    ran = false
    changed(TestSwitch) { ran = true }
    TestSwitch.on
    expect(ran).to be true
  end
end
