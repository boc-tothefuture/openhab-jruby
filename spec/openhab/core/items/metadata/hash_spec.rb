# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Items::Metadata::Hash do
  subject(:namespace) do
    items.build do
      switch_item "TestItem", metadata: {
        "test" => ["value", { "bar" => "baz", "qux" => "quux" }]
      }
    end.metadata["test"]
  end

  describe "#value" do
    it "works" do
      expect(namespace.value).to eql "value"
    end
  end

  describe "#[]" do
    it "works" do
      expect(namespace["bar"]).to eql "baz"
    end
  end

  describe "#dig" do
    it "works" do
      expect(namespace.dig("qux")).to eql "quux" # rubocop:disable Style/SingleArgumentDig
    end

    it "chains to nested hashes" do
      namespace.replace({ "land" => { "cow" => "moo" } })
      expect(namespace.dig("land", "cow")).to eql "moo"
    end
  end

  describe "#[]=" do
    it "works" do
      namespace["bar"] = "corge"
      expect(namespace["bar"]).to eql "corge"
    end

    it "stringifies config keys" do
      namespace[:maxValue] = 10_000
      # JSON round-tripping changes it to a Float
      expect(namespace["maxValue"]).to be 10_000.0
    end

    it "can be added via hash" do
      namespace["bam"] = "corge"
      expect(namespace["bam"]).to eql "corge"
    end
  end

  describe "#==" do
    it "can compare against a ::Hash when the value is empty" do
      namespace.value = ""
      expect(namespace).to eq({ "bar" => "baz", "qux" => "quux" })
    end

    it "can set and compare against a nested hash value" do
      namespace.value = ""
      namespace.replace({ "land" => { "cow" => "moo" } })
      expect(namespace).to eq({ "land" => { "cow" => "moo" } })
    end
  end

  describe "#replace" do
    it "works" do
      namespace.replace("x" => "y")
      expect(namespace.to_h).to eql("x" => "y")
    end

    it "stringifies keys" do
      namespace.replace(maxValue: 10_000)
      # JSON round-tripping changes it to a Float
      expect(namespace.to_h).to eql({ "maxValue" => 10_000.0 })
    end

    it "accepts the config of another namespace" do
      metadata = namespace.item.metadata
      metadata["ns2"] = ["boo", { "moo" => "goo" }]
      namespace.replace(metadata["ns2"])
      expect(namespace.value).to eql "value"
      expect(namespace.to_h).to eql({ "moo" => "goo" })
    end
  end

  describe "#delete" do
    it "works" do
      namespace.delete("bar")
      expect(namespace.to_h).to eql({ "qux" => "quux" })
    end
  end
end
