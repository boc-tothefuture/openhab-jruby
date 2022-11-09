# frozen_string_literal: true

RSpec.describe Time do
  describe "#+" do
    it "works with Duration" do
      now = described_class.now
      expect(now + 1.minute).to eq(now + 60)
    end
  end

  describe "#-" do
    it "works with Duration" do
      now = described_class.now
      expect(now - 1.minute).to eq(now - 60)
    end
  end
end
