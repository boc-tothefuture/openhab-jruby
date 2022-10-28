# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Types::DecimalType do
  subject(:state) { DecimalType::ZERO }

  it "is inspectable" do
    expect(DecimalType.new(10).inspect).to eql "10"
  end

  it "can be converted to QuantityType" do
    expect(DecimalType.new(10) | "°C").to eql QuantityType.new("10 °C")
  end

  it "has numeric predicates" do
    expect(DecimalType.new(0)).to be_zero
    expect(DecimalType.new(0)).not_to be_positive
    expect(DecimalType.new(0)).not_to be_negative
    expect(DecimalType.new(1)).not_to be_zero
    expect(DecimalType.new(1)).to be_positive
    expect(DecimalType.new(1)).not_to be_negative
    expect(DecimalType.new(-1)).not_to be_zero
    expect(DecimalType.new(-1)).not_to be_positive
    expect(DecimalType.new(-1)).to be_negative
  end

  describe "math operations" do
    subject(:state) { DecimalType.new(50) }

    specify { expect(state + 2).to eq 52 }
    specify { expect(state - 2).to eq 48 }
    specify { expect(state / 2).to eq 25 }
    specify { expect(state * 2).to eq 100 }
    specify { expect(state + 2.0).to eq 52 }
    specify { expect(state - 2.0).to eq 48 }
    specify { expect(state / 2.0).to eq 25 }
    specify { expect(state * 2.0).to eq 100 }
  end

  describe "coerced math operations" do
    subject(:state) { DecimalType.new(50) }

    specify { expect(2 + state).to eq 52 }
    specify { expect(2 - state).to eq(-48) }
    specify { expect(2 / state).to eq 0.04 }
    specify { expect(2 * state).to eq 100 }
    specify { expect(2.0 + state).to eq 52 }
    specify { expect(2.0 - state).to eq(-48) }
    specify { expect(2.0 / state).to eq 0.04 }
    specify { expect(2.0 * state).to eq 100 }
  end

  describe "#to_d" do
    it "returns a BigDecimal" do
      expect(state.to_d.class).to be BigDecimal
    end
  end

  describe "#to_i" do
    it "returns an Integer" do
      expect(state.to_i.class).to be Integer
    end
  end

  describe "#to_f" do
    it "returns a Float" do
      expect(state.to_f.class).to be Float
    end
  end

  it "works with grep ranges" do
    numbers = [DecimalType::ZERO, DecimalType.new(70), nil]
    expect(numbers.grep(0...50)).to eq [DecimalType::ZERO]
  end

  it "works in cases" do
    expect(case state
           when 0...50 then 1
           when 50..100 then 2
           end).to be 1
  end

  it "is comparable to floats" do
    expect((0.0...50.0).include?(state)).to be true # rubocop:disable Performance/RangeInclude
  end
end
