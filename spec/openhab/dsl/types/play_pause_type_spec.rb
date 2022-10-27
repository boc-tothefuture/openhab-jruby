# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::PlayPauseType do
  it "is inspectable" do
    expect(PLAY.inspect).to eql "PLAY"
  end

  describe "case statements" do
    specify { expect(PLAY).to be === PLAY }
    specify { expect(1..100).not_to be === PLAY }
    specify { expect(ON).not_to be === PLAY }
    specify { expect(PAUSE).not_to be === PLAY }
    specify { expect(NEXT).not_to be === PLAY }
    specify { expect(PREVIOUS).not_to be === PLAY }
    specify { expect(REWIND).not_to be === PLAY }
    specify { expect(FASTFORWARD).not_to be === PLAY }
  end
end
