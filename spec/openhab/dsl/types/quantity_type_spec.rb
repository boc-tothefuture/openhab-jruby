# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::QuantityType do
  it "is constructible with | from numeric" do
    expect(50 | "°F").to eql QuantityType.new("50.0 °F")
    expect(50.0 | "°F").to eql QuantityType.new("50.0 °F")
    expect(50.to_d | "°F").to eql QuantityType.new("50.0 °F") # rubocop:disable Performance/BigDecimalWithNumericArgument
  end

  it "responds to math operations" do
    # quantity type operand
    expect(QuantityType.new("50 °F") + QuantityType.new("50 °F")).to eql QuantityType.new("100.0 °F")
    expect(QuantityType.new("50 °F") - QuantityType.new("25 °F")).to eql QuantityType.new("25.0 °F")
    expect((QuantityType.new("100 °F") / QuantityType.new("2 °F")).to_i).to be 50
    expect(QuantityType.new("50 °F") + -QuantityType.new("25 °F")).to eql QuantityType.new("25.0 °F")

    # string operand
    expect(QuantityType.new("50 °F") + "50 °F").to eql QuantityType.new("100.0 °F") # rubocop:disable Style/StringConcatenation
    expect(QuantityType.new("50 °F") - "25 °F").to eql QuantityType.new("25.0 °F")

    # numeric operand
    expect(QuantityType.new("50 °F") * 2).to eql QuantityType.new("100.0 °F")
    expect(QuantityType.new("100 °F") / 2).to eql QuantityType.new("50.0 °F")
    expect(QuantityType.new("50 °F") * 2.0).to eql QuantityType.new("100.0 °F")
    expect(QuantityType.new("100 °F") / 2.0).to eql QuantityType.new("50.0 °F")

    # DecimalType operand
    expect(QuantityType.new("50 °F") * DecimalType.new(2)).to eql QuantityType.new("100.0 °F")
    expect(QuantityType.new("100 °F") / DecimalType.new(2)).to eql QuantityType.new("50.0 °F")
    expect(QuantityType.new("50 °F") * DecimalType.new(2.0)).to eql QuantityType.new("100.0 °F")
    expect(QuantityType.new("100 °F") / DecimalType.new(2.0)).to eql QuantityType.new("50.0 °F")
  end

  it "can be compared" do
    expect(QuantityType.new("50 °F")).to be > QuantityType.new("25 °F")
    expect(QuantityType.new("50 °F")).not_to be > QuantityType.new("525 °F")
    expect(QuantityType.new("50 °F")).to be >= QuantityType.new("25 °F")
    expect(QuantityType.new("50 °F")).to eq QuantityType.new("50 °F") # rubocop:disable RSpec/IdenticalEqualityAssertion
    expect(QuantityType.new("50 °F")).to be < QuantityType.new("25 °C")

    expect(QuantityType.new("50 °F")).to eq "50 °F"
    expect(QuantityType.new("50 °F")).to be < "25 °C"
  end

  it "responds to positive?, negative?, and zero?" do
    items.build do
      number_item "NumberF", dimension: "Temperature", format: "%d °F", state: "2 °F"
      number_item "NumberC", dimension: "Temperature", format: "%d °C", state: "2 °C"
      number_item "PowerPos", dimension: "Power", state: "100 W"
      number_item "PowerNeg", dimension: "Power", state: "-100 W"
      number_item "PowerZero", dimension: "Power", state: "0 W"
      number_item "Number1", state: 20
    end

    expect(QuantityType.new("50°F")).to be_positive
    expect(QuantityType.new("-50°F")).to be_negative
    expect(QuantityType.new("10W")).to be_positive
    expect(QuantityType.new("-1kW")).not_to be_positive
    expect(QuantityType.new("0W")).to be_zero
    expect(NumberF).to be_positive
    expect(NumberC).not_to be_negative
    expect(PowerPos).to be_positive
    expect(PowerNeg).to be_negative
    expect(PowerZero).to be_zero
    expect(Number1).to be_positive
  end

  it "converts to another unit with |" do
    expect((0 | "°C") | "°F").to eql QuantityType.new("32 °F")
    expect((1 | "h") | "s").to eql QuantityType.new("3600 s")
  end

  # rubocop:disable RSpec/ExpectActual
  it "supports ranges with string quantity" do
    expect("0 W".."10 W").to cover(0 | "W")
    expect("0 W".."10 W").not_to cover(14 | "W")
    expect("0 W".."10 W").to cover(10 | "W")
  end
  # rubocop:enable RSpec/ExpectActual
end
