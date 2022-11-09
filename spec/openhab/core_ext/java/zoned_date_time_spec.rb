# frozen_string_literal: true

RSpec.describe java.time.ZonedDateTime do
  describe "#to_i" do
    it "returns epoch seconds" do
      now = Time.now
      expect(now.to_zoned_date_time.to_i).to be now.to_i
    end
  end

  describe "#+" do
    it "works with duration" do
      now = ZonedDateTime.now
      expect((now + 5.seconds).to_i).to be(now.to_i + 5)
      expect((now + 2.minutes).to_i).to be(now.to_i + 120)
    end

    it "works with integers" do
      now = ZonedDateTime.now
      expect((now + 5).to_i).to be(now.to_i + 5)
    end
  end

  describe "#-" do
    it "works with duration" do
      now = ZonedDateTime.now
      expect((now - 5.seconds).to_i).to be(now.to_i - 5)
      expect((now - 2.minutes).to_i).to be(now.to_i - 120)
    end

    it "works with integers" do
      now = ZonedDateTime.now
      expect((now - 5).to_i).to be(now.to_i - 5)
    end

    it "returns a duration for another ZonedDateTime instance" do
      now = ZonedDateTime.now
      future = now + 5.seconds
      expect(future - now).to eql 5.seconds
    end

    it "returns a duration for a Time instance" do
      now = ZonedDateTime.now
      future = (now + 5.seconds)
      expect(future - now.to_time).to eql 5.seconds
    end
  end

  describe "#to_date" do
    it "works" do
      expect(ZonedDateTime.parse("2022-11-09T02:09:05+00:00").to_date).to eql Date.new(2022, 11, 9)
    end
  end

  describe "#to_local_date" do
    it "works" do
      expect(ZonedDateTime.parse("2022-11-09T02:09:05+00:00").to_local_date)
        .to eql java.time.LocalDate.parse("2022-11-09")
    end
  end

  describe "#to_local_time" do
    it "works" do
      expect(ZonedDateTime.parse("2022-11-09T02:09:05+00:00").to_local_time)
        .to eql java.time.LocalTime.parse("02:09:05")
    end
  end

  describe "#to_month" do
    it "works" do
      expect(ZonedDateTime.parse("2022-11-09T00:00:00+00:00").to_month).to eql java.time.Month::NOVEMBER
    end
  end

  describe "#to_month_day" do
    it "works" do
      expect(ZonedDateTime.parse("2022-11-09T00:00:00+00:00").to_month_day).to eql java.time.MonthDay.parse("11-09")
    end
  end

  describe "#to_zoned_date_time" do
    it "returns self" do
      now = ZonedDateTime.now
      expect(now.to_zoned_date_time).to be now
    end
  end

  describe "#<=>" do
    let(:zdt) { ZonedDateTime.parse("2022-11-09T02:09:05+00:00") }

    context "with a Time" do
      let(:time) { zdt.to_time }

      specify { expect(zdt).to eq time }
      specify { expect(zdt).not_to eql time }
      specify { expect(zdt).to be <= time }
      specify { expect(zdt).not_to be <= (time - 1) }
      specify { expect(zdt).to be >= time }
      specify { expect(zdt).not_to be >= (time + 1) }
      specify { expect(zdt).not_to be < time }
      specify { expect(zdt).to be < (time + 1) }
      specify { expect(zdt).not_to be > time }
      specify { expect(zdt).to be > (time - 1) }
    end

    context "with a Date" do
      let(:date) { Date.new(2022, 11, 9) }

      specify { expect(zdt).not_to eq date }
      specify { expect(zdt).not_to eql date }
      specify { expect(zdt).to be <= (date + 1) }
      specify { expect(zdt).not_to be <= date }
      specify { expect(zdt).to be >= date }
      specify { expect(zdt).not_to be >= (date + 1) }
      specify { expect(zdt).not_to be < date }
      specify { expect(zdt).to be < (date + 1) }
      specify { expect(zdt).not_to be > (date + 1) }
      specify { expect(zdt).to be > date }
    end

    context "with a LocalDate" do
      let(:date) { java.time.LocalDate.parse("2022-11-09") }

      specify { expect(zdt).not_to eq date }
      specify { expect(zdt).not_to eql date }
      specify { expect(zdt).to be <= (date + 1.day) }
      specify { expect(zdt).not_to be <= date }
      specify { expect(zdt).to be >= date }
      specify { expect(zdt).not_to be >= (date + 1.day) }
      specify { expect(zdt).not_to be < date }
      specify { expect(zdt).to be < (date + 1.day) }
      specify { expect(zdt).not_to be > (date + 1.day) }
      specify { expect(zdt).to be > date }
    end

    context "with a LocalTime" do
      let(:time) { java.time.LocalTime.parse("02:09:05") }

      specify { expect(zdt).to eq time }
      specify { expect(zdt).not_to eql time }
      specify { expect(zdt).to be <= time }
      specify { expect(zdt).not_to be <= (time - 1) }
      specify { expect(zdt).to be >= time }
      specify { expect(zdt).not_to be >= (time + 1) }
      specify { expect(zdt).not_to be < time }
      specify { expect(zdt).to be < (time + 1) }
      specify { expect(zdt).not_to be > time }
      specify { expect(zdt).to be > (time - 1) }
    end

    context "with a Month" do
      let(:oct) { java.time.Month::OCTOBER }
      let(:nov) { java.time.Month::NOVEMBER }
      let(:dec) { java.time.Month::DECEMBER }

      specify { expect(zdt).not_to eq nov }
      specify { expect(zdt).not_to eql nov }
      specify { expect(zdt).to be <= dec }
      specify { expect(zdt).not_to be <= nov }
      specify { expect(zdt).to be >= nov }
      specify { expect(zdt).not_to be >= dec }
      specify { expect(zdt).not_to be < nov }
      specify { expect(zdt).to be < dec }
      specify { expect(zdt).to be > nov }
      specify { expect(zdt).not_to be > dec }
    end

    context "with a MonthDay" do
      let(:date) { java.time.MonthDay.parse("11-09") }

      specify { expect(zdt).not_to eq date }
      specify { expect(zdt).not_to eql date }
      specify { expect(zdt).to be <= (date + 1.day) }
      specify { expect(zdt).not_to be <= date }
      specify { expect(zdt).to be >= date }
      specify { expect(zdt).not_to be >= (date + 1.day) }
      specify { expect(zdt).not_to be < date }
      specify { expect(zdt).to be < (date + 1.day) }
      specify { expect(zdt).to be > date }
      specify { expect(zdt).not_to be > (date + 1.day) }
    end
  end
end
