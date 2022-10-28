# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Types::RewindFastforwardType do
  it "is inspectable" do
    expect(REWIND.inspect).to eql "REWIND"
  end
end
