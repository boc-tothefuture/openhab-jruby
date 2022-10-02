# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::ContactItem do
  subject(:item) do
    items.build do
      contact_item 'ContactOne', 'Contact One'
    end
  end

  it 'can directly compare states' do
    item.update(OPEN)
    expect(item).to eq OPEN
    item.update(CLOSED)
    expect(item).to eq CLOSED
  end

  it 'supports open?/closed? predicates' do
    item.update(OPEN)
    expect(item).to be_open
    item.update(CLOSED)
    expect(item).to be_closed
  end

  it 'can be selected with grep' do
    items.build do
      contact_item 'ContactTwo'
      dimmer_item 'Dimmer'
    end

    expect(items.grep(ContactItem)).to eq [ContactTwo]
  end

  it 'can be selected by state with grep' do
    items.build do
      contact_item 'ContactOne', state: OPEN
      contact_item 'ContactTwo', state: CLOSED
      dimmer_item 'Dimmer'
    end

    expect(items.grep(OPEN)).to eql [ContactOne]
    expect(items.grep(CLOSED)).to eql [ContactTwo]
  end

  it 'supports contact states in case statements' do
    [OPEN, CLOSED].each do |state|
      item.update(state)
      new_state = case item
                  when OPEN then OPEN
                  when CLOSED then CLOSED
                  end
      expect(new_state).to be state
    end
  end

  describe '#to_s' do
    it 'returns state of contact' do
      item.update(OPEN)
      expect(item.to_s).to eql 'OPEN'
    end
  end
end
