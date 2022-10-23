# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::IncreaseDecreaseType do
  it 'is inspectable' do
    expect(INCREASE.inspect).to eql 'INCREASE'
  end
end
