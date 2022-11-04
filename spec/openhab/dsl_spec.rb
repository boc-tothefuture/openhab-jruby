# frozen_string_literal: true

RSpec.describe OpenHAB::DSL do
  it "doesn't leak DSL methods onto other objects" do
    expect { 5.rule }.to raise_error(NoMethodError)
  end

  describe "#script" do
    it "creates triggerable rule" do
      triggered = false
      script id: "testscript" do
        triggered = true
      end

      trigger_rule("testscript")
      expect(triggered).to be true
    end
  end

  describe "#unit" do
    it "converts all units and numbers to specific unit for all operations" do
      c = 23 | "°C"
      f = 70 | "°F"
      expect(unit("°F") { c - f < 4 }).to be true
      expect(unit("°F") { c - "24 °C" < 4 }).to be true
      expect(unit("°F") { QuantityType.new("24 °C") - c < 4 }).to be true
      expect(unit("°C") { f - "20 °C" < 2 }).to be true
      expect(unit("°C") { f - 2 }.format("%.1f %unit%")).to eq "19.1 °C" # rubocop:disable Style/FormatStringToken
      expect(unit("°C") { c + f }.format("%.1f %unit%")).to eq "44.1 °C" # rubocop:disable Style/FormatStringToken
      expect(unit("°C") { f - 2 < 20 }).to be true
      expect(unit("°C") { 2 + c == 25 }).to be true
      expect(unit("°C") { 2 * c == 46 }).to be true
      expect(unit("°C") { (2 * (f + c) / 2) < 45 }).to be true
      expect(unit("°C") { [c, f, 2].min }).to be 2
    end
  end
end
