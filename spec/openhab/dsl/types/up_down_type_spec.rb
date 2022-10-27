# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::UpDownType do
  it "is inspectable" do
    expect(UP.inspect).to eql "UP"
  end

  it "responds to up? and down?" do
    expect(UP.up?).to be true
    expect(UP.down?).to be false
    expect(DOWN.up?).to be false
    expect(DOWN.down?).to be true
  end

  describe "case statements" do
    specify { expect(UP).to be === UP }
    specify { expect(DOWN).not_to be === UP }
    specify { expect(STOP).not_to be === UP }
    specify { expect(MOVE).not_to be === UP }
    specify { expect("UP").not_to be === UP }
    specify { expect(0).not_to be === UP }
    specify { expect(100).not_to be === UP }
    specify { expect(1..100).not_to be === UP }
    specify { expect(DOWN).to be === DOWN }
    specify { expect(UP).not_to be === DOWN }
    specify { expect(INCREASE).not_to be === DOWN }
    specify { expect(DECREASE).not_to be === DOWN }
    specify { expect(PLAY).not_to be === DOWN }
    specify { expect(PAUSE).not_to be === DOWN }
    specify { expect(0..100).not_to be === DOWN }
  end
end
