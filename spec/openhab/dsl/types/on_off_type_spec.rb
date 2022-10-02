# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::OnOffType do
  it 'is inspectable' do
    expect(ON.inspect).to eql 'ON'
  end

  it 'responds to on? and off?' do
    expect(ON).to be_on
    expect(ON).not_to be_off
    expect(OFF).to be_off
    expect(OFF).not_to be_on
  end

  describe 'case statements' do
    specify { expect(ON).to be === ON }
    specify { expect(ON).not_to be === OFF }
    specify { expect(OFF).to be === OFF }
    specify { expect(OFF).not_to be === ON }
    specify { expect(0..99).not_to be === ON }
    specify { expect(100).not_to be === ON }
    specify { expect(INCREASE).not_to be === OFF }
    specify { expect(DECREASE).not_to be === OFF }
    specify { expect(0).not_to be === OFF }
    specify { expect(1..100).not_to be === OFF }
  end

  it 'supports the ! operator' do
    expect(!ON).to eql OFF
    expect(!OFF).to eql ON
  end
end
