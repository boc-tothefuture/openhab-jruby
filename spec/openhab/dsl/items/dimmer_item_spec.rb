# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::DimmerItem do
  subject(:item) { DimmerOne }

  before do
    items.build do
      group_item 'Dimmers' do
        dimmer_item 'DimmerOne', state: 50
        dimmer_item 'DimmerTwo', state: 50
      end
    end
  end

  it 'sends on/off commands' do
    Dimmers.each { |d| d.update(OFF) }
    Dimmers.each(&:on)
    expect(DimmerOne.state).to eql PercentType::HUNDRED
    expect(DimmerTwo.state).to eql PercentType::HUNDRED

    Dimmers.each(&:off)
    expect(DimmerOne.state).to eql PercentType::ZERO
    expect(DimmerTwo.state).to eql PercentType::ZERO
  end

  it 'supports on?/off? predicates' do
    expect(item).to be_on
    expect(item).not_to be_off
    item.update(0)
    expect(item).not_to be_on
    expect(item).to be_off
  end

  describe '#dim and #brighten' do
    specify do
      item.dim 2
      expect(item.state).to eq 48
    end

    specify do
      item.brighten 2
      expect(item.state).to eq 52
    end

    specify do
      item.dim
      expect(item.state).to eq 49
    end

    specify do
      item.brighten
      expect(item.state).to eq 51
    end
  end

  describe '#increase and #decrease' do
    %i[increase decrease].each do |method|
      it "sends #{method} command" do
        received = nil
        received_command item do |event|
          received = event.command
        end

        item.send(method)
        expect(received.to_s).to eql method.to_s.upcase
      end
    end
  end

  describe 'math operations (+,-,/,*)' do
    specify { expect(item + 2).to eq 52 }
    specify { expect(2 + item).to eq 52 }
    specify { expect(item - 2).to eq 48 }
    specify { expect(98 - item).to eq 48 }
    specify { expect(item / 2).to eq 25 }
    specify { expect(100 / item).to eq 2 }
    specify { expect(2 * item).to eq 100 }
  end

  it 'works with grep' do
    items.build { switch_item 'Switch1' }
    expect(items.grep(DimmerItem)).to match_array [DimmerOne, DimmerTwo]
  end

  it 'works with grep in ranges' do
    DimmerOne.update(49)
    DimmerTwo.update(51)
    expect(items.grep(0...50)).to eq [DimmerOne]
  end

  it 'works with states in cases' do
    DimmerOne.update(49)
    DimmerTwo.update(51)
    expect(items.select do |item|
      case item
      when 0..50 then true
      when 51..100 then false
      end
    end).to eq [DimmerOne]
  end

  describe 'comparison to number' do
    specify { expect(item > 50).to be false }
    specify { expect(item == 50).to be true }
    specify { expect(item < 60).to be true }
    specify { expect(DimmerOne == DimmerTwo).to be true }
  end

  describe '#to_s' do
    it 'returns state of dimmer' do
      expect(item.to_s).to eql '50%'
    end
  end
end
