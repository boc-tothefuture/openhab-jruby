# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::ThingUID do
  describe "#inspect" do
    it "logs the full UID" do
      expect(org.openhab.core.thing.ThingUID.new("astro:sun:home").inspect).to eql "astro:sun:home"
    end
  end

  describe "#==" do
    it "works against a regular string" do
      expect(org.openhab.core.thing.ThingUID.new("astro:sun:home")).to eq "astro:sun:home"
    end

    it "works with a string LHS (via ThingUID#to_str)" do
      expect("astro:sun:home").to eq org.openhab.core.thing.ThingUID.new("astro:sun:home") # rubocop:disable RSpec/ExpectActual
    end
  end

  describe "#binding_id" do
    it "returns the correct value" do
      expect(org.openhab.core.thing.ThingUID.new("astro:sun:home").binding_id).to eql "astro"
    end
  end
end
