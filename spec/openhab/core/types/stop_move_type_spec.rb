# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Types::StopMoveType do
  it "is inspectable" do
    expect(STOP.inspect).to eql "STOP"
  end

  describe "case statements" do
    specify { expect(STOP).to be === STOP }
    specify { expect(MOVE).not_to be === STOP }
    specify { expect(0).not_to be === STOP }
    specify { expect(MOVE).to be === MOVE }
    specify { expect(STOP).not_to be === MOVE }
    specify { expect(UP).not_to be === MOVE }
    specify { expect(DOWN).not_to be === MOVE }
  end
end
