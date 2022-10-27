# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::RewindFastforwardType do
  it "is inspectable" do
    expect(REWIND.inspect).to eql "REWIND"
  end
end
