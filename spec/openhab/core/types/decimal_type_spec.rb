# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Types::DecimalType do
  subject(:state) { DecimalType::ZERO }

  let(:ten) { DecimalType.new(10) }

  it "is inspectable" do
    expect(ten.inspect).to eql "10"
  end

  it "can be converted to QuantityType" do
    expect(ten | "°C").to eql QuantityType.new("10 °C")
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

  describe "comparisons" do
    let(:twenty) { DecimalType.new(20) }
    let(:five) { DecimalType.new(5) }
    let(:ten_percent) { PercentType.new(10) }
    let(:five_percent) { PercentType.new(5) }

    # DecimalType vs UnDefType
    specify { expect(ten).not_to eq(NULL) }
    specify { expect(ten).not_to eq(UNDEF) }

    # DecimalType vs DecimalType
    specify { expect(ten).to eql ten }
    specify { expect(ten).to eq ten }
    specify { expect(ten).not_to eq(five) }
    specify { expect(ten != five).to be true }
    specify { expect(ten != ten).to be false }

    specify { expect(ten).to be < twenty }
    specify { expect(ten).not_to be < five }
    specify { expect(ten).to be > five }
    specify { expect(ten).not_to be > twenty }

    # DecimalType vs Numeric
    specify { expect(ten).not_to eql 10 }
    specify { expect(ten).to eq 10 }
    specify { expect(ten).not_to eq 1 }
    specify { expect(ten != 1).to be true }
    specify { expect(ten != 10).to be false }

    specify { expect(ten).to be < 10.1 }
    specify { expect(ten).not_to be < 5 }
    specify { expect(ten).to be > 5 }
    specify { expect(ten).not_to be > 10.1 }

    # Numeric vs DecimalType
    specify { expect(10).not_to eql ten }
    specify { expect(10).to eq ten }
    specify { expect(10).not_to eq five }
    specify { expect(10 != five).to be true }
    specify { expect(10 != ten).to be false }

    specify { expect(10.5).to be < twenty }
    specify { expect(10).not_to be < five }
    specify { expect(10).to be > five }
    specify { expect(10).not_to be > ten }

    # DecimalType vs PercentType
    specify { expect(ten).not_to eql ten_percent }
    specify { expect(ten).to eq ten_percent }
    specify { expect(ten).not_to eq five_percent }
    specify { expect(ten != five_percent).to be true }
    specify { expect(ten != ten_percent).to be false }

    specify { expect(five).to be < ten_percent }
    specify { expect(ten).not_to be < five_percent }
    specify { expect(ten).to be > five_percent }
    specify { expect(five).not_to be > five_percent }
  end
end
