# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::DateTimeItem do
  before do
    items.build do
      date_time_item 'DateOne', state: '1970-01-01T00:00:00+00:00'
      date_time_item 'DateTwo', state: '2021-01-31T08:00:00+00:00'
      date_time_item 'DateThree', state: '2021-01-31T14:00:00+06:00'
    end
  end

  describe 'math operations' do
    before { DateOne.update('1970-01-31T08:00:00+0200') }

    specify { expect(DateOne + 600).to eq '1970-01-31T08:10:00.000+0200' }
    specify { expect(DateOne - 600).to eq '1970-01-31T07:50:00.000+0200' }
    specify { expect(DateOne + '00:05').to eq '1970-01-31T08:05:00.000+0200' } # rubocop:disable Style/StringConcatenation
    specify { expect(DateOne - '00:05').to eq '1970-01-31T07:55:00.000+0200' }
    specify { expect(DateOne + 20.minutes).to eq '1970-01-31T08:20:00.000+0200' }
    specify { expect(DateOne - 20.minutes).to eq '1970-01-31T07:40:00.000+0200' }
  end

  describe 'Ruby time methods' do
    specify { expect(DateTwo).to be_sunday }
    specify { expect(DateTwo).not_to be_monday }
    specify { expect(DateTwo.wday).to be 0 }
    specify { expect(DateTwo).to be_utc }
    specify { expect(DateTwo.month).to be 1 }
    specify { expect(DateTwo.zone).to eql 'Z' }
  end

  it 'considers same time but different zone to be equal' do
    expect(DateTwo).to eq DateThree
  end

  it 'can be updated by Ruby Time objects' do
    DateOne << Time.at(60 * 60 * 24).utc
    expect(DateOne.state).to eq '1970-01-02T00:00:00.000+0000'
  end

  describe 'calculating time differences' do
    before { DateOne.update('2021-01-31T09:00:00+00:00') }

    specify { expect((DateOne - '2021-01-31T07:00:00+00:00').to_i).to be 7200 }
    specify { expect((DateOne - Time.utc(2021, 1, 31, 7)).to_i).to be 7200 }
    specify { expect((DateOne - DateTwo).to_i).to be 3600 }
  end

  it 'works with TimeOfDay ranges' do
    expect(
      case DateThree
      when between('00:00'...'08:00') then 1
      when between('08:00'...'16:00') then 2
      when between('16:00'..'23:59') then 3
      end
    ).to be 2
  end

  it 'can create between ranges' do
    expect(between(DateOne...DateTwo)).to cover('05:00')
  end

  it 'accepts ZonedDateTime' do
    DateOne << ZonedDateTime.of(1999, 12, 31, 0, 0, 0, 0, ZoneId.of('UTC'))
    expect(DateOne.state).to eq '1999-12-31T00:00:00.000+0000'
  end
end
