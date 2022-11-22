# frozen_string_literal: true

RSpec.describe Time do
  describe "#+" do
    it "works with Duration" do
      now = described_class.now
      expect(now + 1.minute).to eq(now + 60)
    end
  end

  describe "#-" do
    it "works with Duration and returns a ZonedDateTime" do
      now = described_class.now
      result = now - 1.minute
      expect(result).to eq(now - 60)
      expect(result).to be_a(java.time.ZonedDateTime)
    end

    it "works with ZonedDateTime and returns a Duration" do
      now = described_class.now
      zdt = now.to_zoned_date_time.minus_minutes(1)
      result = now - zdt
      expect(result).to eq(1.minute)
      expect(result).to be_a(java.time.Duration)
    end

    it "works with Numeric and returns a Time" do
      Timecop.freeze
      result = described_class.now - 60
      expect(result.to_i).to eq(60.seconds.ago.to_i)
      expect(result).to be_a(described_class)
    end

    it "works with another Time and returns a Float" do
      one_day_in_secs = described_class.new(2002, 10, 31) - described_class.new(2002, 10, 30)
      expect(one_day_in_secs).to eq(86_400)
      expect(one_day_in_secs).to be_a(Numeric)
    end
  end
end
