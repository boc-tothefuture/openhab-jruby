# frozen_string_literal: true

RSpec.describe Duration do
  it "is constructible from various numbers" do
    expect(5.seconds).to be_a(described_class)
    expect(5.minutes).to be_a(described_class)
    expect(5.hours).to be_a(described_class)
    expect(5.5.seconds).to be_a(described_class)
    expect(5.5.minutes).to be_a(described_class)
    expect(5.5.hours).to be_a(described_class)
  end

  it "is comparable to numeric" do
    expect(5.seconds).to eq 5
    expect(5.seconds).to eq 5
  end

  it "is addable and subtractable" do
    expect(60.seconds + 5).to eql 65.seconds
    expect(5 + 60.seconds).to eql 65.seconds
    expect(1.hour + 5.minutes).to eql 65.minutes
    expect(1.hour - 5.minutes).to eql 55.minutes
    expect(60.seconds - 5).to eql 55.seconds
    expect(60 - 5.seconds).to eql 55.seconds
  end

  describe "#to_i" do
    it "returns seconds" do
      expect(5.seconds.to_i).to be 5
      expect(1.minute.to_i).to be 60
    end
  end

  describe "#ago" do
    it "works" do
      Timecop.freeze
      now = ZonedDateTime.now
      expect(5.minutes.ago).to eql now - 5.minutes
    end
  end

  describe "#from_now" do
    it "works" do
      Timecop.freeze
      now = ZonedDateTime.now
      expect(5.minutes.from_now).to eql now + 5.minutes
    end
  end

  describe "#between?" do
    it "works with min, max" do
      expect(10.seconds.between?(1.second, 1.hour)).to be true
      expect(10.seconds.between?(10.seconds, 1.hour)).to be true
      expect(10.seconds.between?(1.second, 10.seconds)).to be true
      expect(10.seconds.between?(1.second, 5.seconds)).to be false
      expect(10.seconds.between?(1.hour, 2.hours)).to be false
    end

    it "works with range" do
      expect(10.seconds.between?((1.second)..(1.hour))).to be true
      expect(10.seconds.between?((1.second)..(10.seconds))).to be true
      expect(10.seconds.between?((1.second)...(10.seconds))).to be false
      expect(10.seconds.between?((1.second)..)).to be true
    end
  end
end
