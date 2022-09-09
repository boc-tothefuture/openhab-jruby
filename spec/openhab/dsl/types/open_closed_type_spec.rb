# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::OpenClosedType do
  it 'is inspectable' do
    expect(OPEN.inspect).to eql 'OPEN'
  end

  it 'supports the ! operator' do
    expect(!OPEN).to eql CLOSED
    expect(!CLOSED).to eql OPEN
  end
end
