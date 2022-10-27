# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::SwitchItem do
  subject(:item) { SwitchOne }

  before { items.build { switch_item "SwitchOne" } }

  describe "commands" do
    specify { expect(item.on).to be_on }
    specify { expect(item.off).to be_off }
  end

  it "accepts boolean values" do
    expect((item << true).state).to be ON
    expect((item << false).state).to be OFF
  end

  describe "#toggle" do
    specify do
      item.on.toggle
      expect(item.state).to be OFF
    end

    specify do
      item.off.toggle
      expect(item.state).to be ON
    end

    specify do
      item.update(UNDEF).toggle
      expect(item.state).to be ON
    end

    specify do
      item.update(NULL).toggle
      expect(item.state).to be ON
    end
  end

  it "works with grep" do
    items.build { string_item "StringOne" }
    expect(items.grep(SwitchItem)).to eql [item]
  end
end
