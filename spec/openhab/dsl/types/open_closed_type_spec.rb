# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::OpenClosedType do
  it "is inspectable" do
    expect(OPEN.inspect).to eql "OPEN"
  end

  it "supports the ! operator" do
    expect(!OPEN).to eql CLOSED
    expect(!CLOSED).to eql OPEN
  end

  it "supports contact states in case statements" do
    [OPEN, CLOSED].each do |state|
      new_state = case state
                  when OPEN then OPEN
                  when CLOSED then CLOSED
                  end
      expect(new_state).to be state
    end
  end
end
