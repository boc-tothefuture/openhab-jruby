# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::PlayPauseType do
  it 'is inspectable' do
    expect(PLAY.inspect).to eql 'PLAY'
  end
end
