# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Rules::Terse do
  it "works" do
    this = self
    items.build { switch_item "TestSwitch" }
    ran = false
    changed TestSwitch do
      ran = true
      expect(self).to be this
    end
    TestSwitch.on
    expect(ran).to be true
  end

  it "requires a block" do
    items.build { switch_item "TestSwitch" }
    expect { changed(TestSwitch) }.to raise_error(ArgumentError)
  end
end
