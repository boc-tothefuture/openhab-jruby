# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Types::StringType do
  it "is inspectable" do
    expect(StringType.new("my_string").inspect).to eql '"my_string"'
  end

  it "converts to a string" do
    expect(StringType.new("my_string").to_s).to eql "my_string"
  end

  it "can be used in a case with a regex" do
    result = case StringType.new("hi")
             when /hi/ then true
             else false
             end
    expect(result).to be true
  end

  it "can use =~ operator" do
    expect(StringType.new("hi") =~ /[a-z]+/).to be 0
  end
end
