# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Types::RefreshType do
  it "is inspectable" do
    expect(REFRESH.inspect).to eql "REFRESH"
  end
end
