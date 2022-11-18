# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Items::Metadata::NamespaceHash do
  subject(:metadata) do
    items.build do
      switch_item "TestItem", metadata: {
        "test" => ["value", { "bar" => "baz", "qux" => "quux" }]
      }
    end.metadata
  end

  let(:metadata2) do
    items.build do
      switch_item "Item2", metadata: {
        "ts2" => ["boo", { "moo" => "goo" }]
      }
    end
    Item2.metadata
  end

  describe "#[]=" do
    it "stringifies keys" do
      metadata["homekit"] = "", { maxValue: 10_000 }
      expect(metadata["homekit"].to_h).to eql({ "maxValue" => 10_000 })
    end

    it "replaces entire metadata with value" do
      metadata["test"] = "corge"
      expect(metadata["test"].value).to eql "corge"
      expect(metadata["test"]).to be_empty
    end

    it "stringifies namesapce value" do
      metadata["test"] = 5
      expect(metadata["test"].value).to eql "5"
      expect(metadata["test"]).to be_empty
    end

    it "replaces entire metadata with Hash" do
      metadata["test"] = { "x" => "y" }
      expect(metadata["test"].value).to eql ""
      expect(metadata["test"].to_h).to eql({ "x" => "y" })
    end

    it "replaces entire metadata" do
      metadata["test"] = "bit", { "x" => "y" }
      expect(metadata["test"].value).to eql "bit"
      expect(metadata["test"].to_h).to eql({ "x" => "y" })
    end

    it "adds new namespaces" do
      metadata["new"] = "foo", { "bar" => "baz" }
      expect(metadata["new"].value).to eql "foo"
      expect(metadata["new"].to_h).to eql({ "bar" => "baz" })
    end

    it "can set value and preserve initial config" do
      metadata["test"] = "val", metadata["test"]
      expect(metadata["test"].value).to eql "val"
      expect(metadata["test"].to_h).to eql({ "bar" => "baz", "qux" => "quux" })
    end

    it "can set value with and preserve initial config with non-existent namespace" do
      metadata["test2"] = "val2", metadata["test2"]
      expect(metadata["test2"].value).to eql "val2"
      expect(metadata["test2"]).to be_empty
    end

    it "can assign entire namespace from another item" do
      metadata["test"] = metadata2["ts2"]
      expect(metadata["test"].value).to eql "boo"
      expect(metadata["test"].to_h).to eql({ "moo" => "goo" })
      # make sure it "works" doesn't modify the original item
      metadata["test"].value = "baa"
      expect(metadata["test"].value).to eql "baa"
      expect(metadata2["ts2"].value).to eql "boo"
    end
  end

  describe "#key?" do
    it "finds keys" do
      expect(metadata).to have_key("test")
    end

    it "does not find missing keys" do
      expect(metadata).not_to have_key("test2")
    end
  end

  describe "#delete" do
    it "works" do
      metadata.delete("test")
      expect(metadata.key?("test")).to be false
    end
  end

  describe "#empty?" do
    it "works" do
      expect(metadata).not_to be_empty
    end
  end

  describe "#keys" do
    it "works" do
      expect(metadata.keys).to eql ["test"]
    end
  end

  describe "#clear" do
    it "works" do
      metadata.clear
      expect(metadata).to be_empty
    end
  end

  describe "#merge" do
    it "works with a Hash" do
      metadata.merge!("n1" => ["baz", { "foo" => "bar" }], "n2" => ["boo", { "moo" => "goo" }])
      expect(metadata).to have_key("test")
      expect(metadata["n1"].value).to eql "baz"
      expect(metadata["n1"].to_h).to eql({ "foo" => "bar" })
      expect(metadata["n2"].value).to eql "boo"
      expect(metadata["n2"].to_h).to eql({ "moo" => "goo" })
    end

    it "works with another item's metadata" do
      metadata.merge!(metadata2)
      expect(metadata).to have_key("test")
      expect(metadata["ts2"].value).to eql "boo"
      expect(metadata["ts2"].to_h).to eql({ "moo" => "goo" })
    end
  end

  describe "#dig" do
    it "works" do
      expect(metadata.dig("test")).to be_a(OpenHAB::Core::Items::Metadata::Hash) # rubocop:disable Style/SingleArgumentDig
      expect(metadata.dig("test", "qux")).to eql "quux"
      expect(metadata.dig("nonexistent", "qux")).to be_nil
      expect(metadata.dig("test", "nonexistent")).to be_nil
    end
  end
end
