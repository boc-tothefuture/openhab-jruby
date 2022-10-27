# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::NumberItem do
  subject(:item) { NumberOne }

  before do
    items.build do
      group_item "Numbers" do
        number_item "NumberOne", state: 0
        number_item "NumberTwo", state: 70
      end
      number_item "NumberNull"
    end
  end

  describe "math operations" do
    before { item.update(50) }

    specify { expect(item + 2).to eq 52 }
    specify { expect(item - 2).to eq 48 }
    specify { expect(item / 2).to eq 25 }
    specify { expect(item * 2).to eq 100 }
    specify { expect(item + 2.0).to eq 52 }
    specify { expect(item - 2.0).to eq 48 }
    specify { expect(item / 2.0).to eq 25 }
    specify { expect(item * 2.0).to eq 100 }
  end

  describe "coerced math operations" do
    before { item.update(50) }

    specify { expect(2 + item).to eq 52 }
    specify { expect(2 - item).to eq(-48) }
    specify { expect(2 / item).to eq 0.04 }
    specify { expect(2 * item).to eq 100 }
    specify { expect(2.0 + item).to eq 52 }
    specify { expect(2.0 - item).to eq(-48) }
    specify { expect(2.0 / item).to eq 0.04 }
    specify { expect(2.0 * item).to eq 100 }
  end

  describe "#to_d" do
    it "returns a BigDecimal" do
      expect(item.to_d.class).to be BigDecimal
    end
  end

  describe "#to_i" do
    it "returns an Integer" do
      expect(item.to_i.class).to be Integer
    end
  end

  describe "#to_f" do
    it "returns a Float" do
      expect(item.to_f.class).to be Float
    end
  end

  it "works with grep" do
    items.build { switch_item "Switch1" }
    expect(items.grep(NumberItem)).to match_array [NumberOne, NumberTwo, NumberNull]
  end

  it "works with grep ranges" do
    expect(Numbers.grep(0...50)).to eq [NumberOne]
  end

  it "works in cases" do
    expect(case item
           when 0...50 then 1
           when 50..100 then 2
           end).to be 1
  end

  it "is comparable to floats" do
    expect((0.0...50.0).include?(NumberOne)).to be true # rubocop:disable Performance/RangeInclude
  end

  describe "#positive?" do
    specify { expect(NumberTwo).to be_positive }
    specify { expect(NumberNull).not_to be_positive }
  end

  it "can be converted to QuantityType" do
    expect(NumberTwo | "°C").to eq QuantityType.new("70 °C")
  end
end
