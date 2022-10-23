# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::UpDownType do
  it 'is inspectable' do
    expect(UP.inspect).to eql 'UP'
  end

  it 'responds to up? and down?' do
    expect(UP.up?).to be true
    expect(UP.down?).to be false
    expect(DOWN.up?).to be false
    expect(DOWN.down?).to be true
  end
end
