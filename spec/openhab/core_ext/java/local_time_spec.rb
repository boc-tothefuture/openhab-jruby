# frozen_string_literal: true

RSpec.describe java.time.LocalTime do
  let(:time) { java.time.LocalTime.parse("03:22:01") }

  describe "#+" do
    it "works with a Period" do
      expect(time + 1.year).to be time
      expect(time + 1.day).to be time
    end

    it "works with a Duration" do
      expect(time + 2.hours).to eql java.time.LocalTime.parse("05:22:01")
    end

    it "works with integers" do
      expect(time + 1).to eql java.time.LocalTime.parse("03:22:02")
    end
  end

  describe "#-" do
    it "works with a Period" do
      expect(time - 1.year).to be time
      expect(time - 1.day).to be time
    end

    it "works with a Duration" do
      expect(time - 2.hours).to eql java.time.LocalTime.parse("01:22:01")
    end

    it "works with integers" do
      expect(time - 1).to eql java.time.LocalTime.parse("03:22:00")
    end
  end

  describe "#to_zoned_date_time" do
    it "takes on the date of the contextual time" do
      context = ZonedDateTime.parse("1990-05-04T03:02:01+03:00")
      expect(time.to_zoned_date_time(context)).to eql ZonedDateTime.parse("1990-05-04T03:22:01+03:00")
      expect(time.to_zoned_date_time.month_value).to be Time.now.month
    end
  end

  describe "#succ" do
    it "works" do
      expect(time.succ).to eql java.time.LocalTime.parse("03:22:02")
    end

    it "rolls across midnight" do
      expect(java.time.LocalTime.parse("23:59:59").succ).to eql java.time.LocalTime.parse("00:00:00")
    end
  end

  describe "#<=>" do
    context "with a LocalTime" do
      let(:other) { java.time.LocalTime.parse("03:22:01") }

      specify { expect(time).to eq other }
      specify { expect(time).to eql other }
      specify { expect(time).to be <= other }
      specify { expect(time).not_to be <= (other - 1.second) }
      specify { expect(time).to be >= other }
      specify { expect(time).not_to be >= (other + 1.second) }
      specify { expect(time).not_to be < other }
      specify { expect(time).to be < (other + 1.second) }
      specify { expect(time).not_to be > other }
      specify { expect(time).to be > (other - 1.second) }
    end

    context "with a ZonedDateTime" do
      let(:other) { time.to_zoned_date_time }

      specify { expect(time).to eq other }
      specify { expect(time).not_to eql other }
      specify { expect(time).to be <= other }
      specify { expect(time).not_to be <= (other - 1.second) }
      specify { expect(time).to be >= other }
      specify { expect(time).not_to be >= (other + 1.second) }
      specify { expect(time).not_to be < other }
      specify { expect(time).to be < (other + 1.second) }
      specify { expect(time).not_to be > other }
      specify { expect(time).to be > (other - 1.second) }
    end

    context "with a Time" do
      let(:other) { time.to_zoned_date_time.to_time }

      specify { expect(time).to eq other }
      specify { expect(time).not_to eql other }
      specify { expect(time).to be <= other }
      specify { expect(time).not_to be <= (other - 1) }
      specify { expect(time).to be >= other }
      specify { expect(time).not_to be >= (other + 1) }
      specify { expect(time).not_to be < other }
      specify { expect(time).to be < (other + 1) }
      specify { expect(time).not_to be > other }
      specify { expect(time).to be > (other - 1) }
    end
  end
end
