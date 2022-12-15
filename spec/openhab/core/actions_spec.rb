# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Actions do
  %i[Exec HTTP Ping].each do |action|
    it "#{action} is available" do
      expect(described_class.constants).to include(action)
    end
  end

  it "Ping#check_vitality works" do
    expect(Ping.check_vitality(nil, 80, 1)).to be false
  end
end
