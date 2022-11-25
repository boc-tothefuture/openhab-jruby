# frozen_string_literal: true

RSpec.describe DateTime do
  describe "#+" do
    it "works with Duration" do
      now = described_class.now
      expect(now + 1.day).to eq(now + 1)
    end
  end

  describe "#-" do
    it "works with Duration and returns a ZonedDateTime" do
      now = described_class.now
      result = now - 1.day
      expect(result).to eq(now - 1)
      expect(result).to be_a(java.time.ZonedDateTime)
    end

    it "works with ZonedDateTime and returns a Duration" do
      now = described_class.now
      zdt = now.to_zoned_date_time.minus_minutes(1)
      result = now - zdt
      expect(result).to eq(1.minute)
      expect(result).to be_a(java.time.Duration)
    end

    it "works with Numeric and returns a DateTime" do
      Timecop.freeze
      result = described_class.now - 1
      expect(result).to eq 1.day.ago
      expect(result).to be_a(described_class)
    end

    it "works with another DateTime and returns a Float" do
      one_day_in_secs = described_class.new(2002, 10, 31) - described_class.new(2002, 10, 30)
      expect(one_day_in_secs).to eq(1)
      expect(one_day_in_secs).to be_a(Rational)
    end
  end
end
