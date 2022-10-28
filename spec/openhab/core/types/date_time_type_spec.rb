# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Types::DateTimeType do
  let(:date1) { DateTimeType.new("1970-01-01T00:00:00+00:00") }
  let(:date2) { DateTimeType.new("2021-01-31T08:00:00+00:00") }
  let(:date3) { DateTimeType.new("2021-01-31T14:00:00+06:00") }

  describe "math operations" do
    let(:date1) { DateTimeType.new("1970-01-31T08:00:00+0200") }

    specify { expect(date1 + 600).to eq "1970-01-31T08:10:00.000+0200" }
    specify { expect(date1 - 600).to eq "1970-01-31T07:50:00.000+0200" }
    specify { expect(date1 + "00:05").to eq "1970-01-31T08:05:00.000+0200" } # rubocop:disable Style/StringConcatenation
    specify { expect(date1 - "00:05").to eq "1970-01-31T07:55:00.000+0200" }
    specify { expect(date1 + 20.minutes).to eq "1970-01-31T08:20:00.000+0200" }
    specify { expect(date1 - 20.minutes).to eq "1970-01-31T07:40:00.000+0200" }
  end

  describe "Ruby time methods" do
    specify { expect(date2).to be_sunday }
    specify { expect(date2).not_to be_monday }
    specify { expect(date2.wday).to be 0 }
    specify { expect(date2).to be_utc }
    specify { expect(date2.month).to be 1 }
    specify { expect(date2.zone).to eql "Z" }
  end

  it "considers same time but different zone to be equal" do
    expect(date2).to eq date3
  end

  describe "calculating time differences" do
    let(:date1) { DateTimeType.new("2021-01-31T09:00:00+00:00") }

    specify { expect((date1 - "2021-01-31T07:00:00+00:00").to_i).to be 7200 }
    specify { expect((date1 - Time.utc(2021, 1, 31, 7)).to_i).to be 7200 }
    specify { expect((date1 - date2).to_i).to be 3600 }
  end

  it "works with TimeOfDay ranges" do
    expect(
      case date3
      when between("00:00"..."08:00") then 1
      when between("08:00"..."16:00") then 2
      when between("16:00".."23:59") then 3
      end
    ).to be 2
  end

  it "can create between ranges" do
    expect(between(date1...date2)).to cover("05:00")
  end
end
