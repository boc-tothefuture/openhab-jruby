# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Things::ThingUID do
  describe "#inspect" do
    it "logs the full UID" do
      expect(described_class.new("astro:sun:home").inspect).to eql "astro:sun:home"
    end
  end

  describe "#==" do
    it "works against a regular string" do
      expect(described_class.new("astro:sun:home")).to eq "astro:sun:home"
    end

    it "works with a string LHS (via ThingUID#to_str)" do
      expect("astro:sun:home").to eq described_class.new("astro:sun:home") # rubocop:disable RSpec/ExpectActual
    end
  end

  describe "#binding_id" do
    it "returns the correct value" do
      expect(described_class.new("astro:sun:home").binding_id).to eql "astro"
    end
  end
end
