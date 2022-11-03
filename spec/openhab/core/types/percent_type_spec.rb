# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Types::PercentType do
  let(:state) { PercentType.new(50) }

  it "is inspectable" do
    expect(PercentType.new(10).inspect).to eql "10%"
  end

  it "responds to on?, off?, up?, and down?" do
    state = PercentType.new(0)
    expect(state).to be_up
    expect(state).not_to be_down
    expect(state).not_to be_on
    expect(state).to be_off
    state = PercentType.new(50)
    expect(state).not_to be_up
    expect(state).not_to be_down
    expect(state).to be_on
    expect(state).not_to be_off
    state = PercentType.new(100)
    expect(state).not_to be_up
    expect(state).to be_down
    expect(state).to be_on
    expect(state).not_to be_off
  end

  it "can scale" do
    expect(PercentType.new(0).scale(0..255)).to be 0
    expect(PercentType.new(100).scale(0..255)).to be 255
    expect(PercentType.new(100).scale(0...256)).to be 255
    expect(PercentType.new(0).scale(25..75)).to be 25
    expect(PercentType.new(50).scale(25..75)).to be 50
    expect(PercentType.new(100).scale(25..75)).to be 75
    expect(PercentType.new(50).scale(-50..10.0)).to be(-20.0)
    expect(PercentType.new(100).scale(-50..10.0)).to be 10.0
  end

  it "handles #to_byte" do
    expect(PercentType.new(50).to_byte).to be 128
  end

  describe "case statements" do
    specify { expect(OFF).not_to be === PercentType::ZERO }
    specify { expect(ON).not_to be === PercentType::ZERO }
    specify { expect(DECREASE).not_to be === PercentType::ZERO }
    specify { expect(STOP).not_to be === PercentType::ZERO }
    specify { expect(MOVE).not_to be === PercentType::ZERO }
    specify { expect(UP).not_to be === PercentType::ZERO }
    specify { expect(DOWN).not_to be === PercentType::ZERO }
    specify { expect(0).to be === PercentType::ZERO }
    specify { expect(0..50).to be === PercentType::ZERO }
    specify { expect(ON).not_to be === PercentType.new(50) }
    specify { expect(INCREASE).not_to be === PercentType.new(50) }
    specify { expect(50).to be === PercentType.new(50) }
    specify { expect(ON).not_to be === PercentType::HUNDRED }
    specify { expect(STOP).not_to be === PercentType::HUNDRED }
    specify { expect(MOVE).not_to be === PercentType::HUNDRED }
    specify { expect(UP).not_to be === PercentType::HUNDRED }
    specify { expect(DOWN).not_to be === PercentType::HUNDRED }
    specify { expect(0..99).not_to be === PercentType::HUNDRED }
    specify { expect(100).to be === PercentType::HUNDRED }
  end

  describe "comparison to number" do
    specify { expect(state > 50).to be false }
    specify { expect(state == 50).to be true }
    specify { expect(state < 60).to be true }
    specify { expect(state == PercentType.new(50)).to be true }
  end

  describe "math operations" do
    specify { expect(state + 20).to eq 70 }
    specify { expect(state - 20).to eq 30 }
    specify { expect(state * 2).to eq 100 }
    specify { expect(state / 2).to eq 25 }
    specify { expect(20 + state).to eq 70 }
    specify { expect(90 - state).to eq 40 }
    specify { expect(2 * state).to eq 100 }
    specify { expect(100 / state).to eq 2 }
    specify { expect(70 % state).to eq 20 }
  end

  describe "ranges" do
    specify { expect(0...50).not_to be === PercentType.new(55) }
    specify { expect(50..100).to be === PercentType.new(55) }
  end
end
