# frozen_string_literal: true

RSpec.describe Date do
  describe "#+" do
    it "works with Period" do
      now = described_class.today
      expect(now + 1.day).to eq(now + 1)
    end
  end

  describe "#-" do
    it "works with Period and returns a LocalDate" do
      now = described_class.today
      result = now - 1.day
      expect(result).to eq(now - 1)
      expect(result).to be_a(java.time.LocalDate)
    end

    it "works with LocalDate and returns a Period" do
      now = described_class.today
      ld = now.to_local_date.minus_days(1)
      result = now - ld
      expect(result).to eq(1.day)
      expect(result).to be_a(java.time.Period)
    end

    it "works with Numeric and returns a Date" do
      Timecop.freeze
      result = described_class.today - 1
      expect(result).to eq 1.day.ago
      expect(result).to be_a(described_class)
    end

    it "works with another Date and returns a Rational" do
      one_day = described_class.new(2002, 10, 31) - described_class.new(2002, 10, 30)
      expect(one_day).to eq(1)
      expect(one_day).to be_a(Rational)
    end
  end
end
