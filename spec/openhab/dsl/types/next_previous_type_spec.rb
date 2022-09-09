# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::NextPreviousType do
  it 'is inspectable' do
    expect(NEXT.inspect).to eql 'NEXT'
  end
end
