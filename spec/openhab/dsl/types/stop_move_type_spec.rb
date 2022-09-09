# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::StopMoveType do
  it 'is inspectable' do
    expect(STOP.inspect).to eql 'STOP'
  end
end
