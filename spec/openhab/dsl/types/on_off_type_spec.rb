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

  it 'can be used in case statements' do
    [ON, OFF].each do |state|
      result = case state
               when ON then ON
               when OFF then OFF
               end
      expect(result).to be state
    end
  end

  it 'supports the ! operator' do
    expect(!ON).to eql OFF
    expect(!OFF).to eql ON
  end
end
