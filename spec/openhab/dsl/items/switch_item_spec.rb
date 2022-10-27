# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::SwitchItem do
  subject(:item) { SwitchOne }

  before { items.build { switch_item "SwitchOne" } }

  describe "commands" do
    specify { expect(item.on).to be_on }
    specify { expect(item.off).to be_off }
  end

  it "accepts booelan values" do
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

  describe "\#@!" do
    specify { expect(!item.on).to be OFF }
    specify { expect(!item.off).to be ON }
    specify { expect(!item.update(UNDEF)).to be ON }
    specify { expect(!item.update(NULL)).to be ON }
  end

  it "works with grep" do
    items.build { string_item "StringOne" }
    expect(items.grep(SwitchItem)).to eql [item]
  end

  it "works with grep for states" do
    items.build do
      switch_item "SwitchTwo", state: OFF
      string_item "StringOne"
    end
    SwitchOne.on
    expect(items.grep(ON)).to eql [SwitchOne]
    expect(items.grep(OFF)).to eql [SwitchTwo]
  end

  it "works with states in cases" do
    items.build {            switch_item "SwitchTwo", state: OFF }
    SwitchOne.on

    expect([SwitchOne, SwitchTwo].map do |switch|
      case switch
      when ON then ON
      when OFF then OFF
      end
    end).to eql [ON, OFF]
  end
end
