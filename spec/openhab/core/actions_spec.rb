# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Actions do
  %i[Exec HTTP Ping].each do |action|
    it "#{action} is available" do
      expect(described_class.constants).to include(action)
    end
  end

  it "Ping#check_vitality is available at the root" do
    expect(check_vitality(nil, 80, 1)).to be false
    expect(check_vitality("127.0.0.1", 0, 1)).to be true
  end

  it "Ping#check_vitality is available on DSL" do
    expect(OpenHAB::DSL.check_vitality(nil, 80, 1)).to be false
  end

  it "Ping#check_vitality is available on Actions" do
    expect(described_class.check_vitality(nil, 80, 1)).to be false
  end

  it "Ping#check_vitality is available explicitly" do
    expect(OpenHAB::Core::Actions::Ping.check_vitality(nil, 80, 1)).to be false
  end
end
