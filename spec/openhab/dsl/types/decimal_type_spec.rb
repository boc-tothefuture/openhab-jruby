# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::DecimalType do
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
end
