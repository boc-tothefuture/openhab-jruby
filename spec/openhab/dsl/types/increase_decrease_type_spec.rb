# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::IncreaseDecreaseType do
  it 'is inspectable' do
    expect(INCREASE.inspect).to eql 'INCREASE'
  end

  describe 'case statements' do
    specify { expect(ON).not_to be === INCREASE }
    specify { expect(DECREASE).not_to be === INCREASE }
    specify { expect(0..100).not_to be === INCREASE }
    specify { expect(INCREASE).to be === INCREASE }
    specify { expect(OFF).not_to be === DECREASE }
    specify { expect(0).not_to be === DECREASE }
    specify { expect(INCREASE).not_to be === DECREASE }
    specify { expect(DECREASE).to be === DECREASE }
  end
end
