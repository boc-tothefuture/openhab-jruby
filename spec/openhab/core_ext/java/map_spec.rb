# frozen_string_literal: true

RSpec.describe java.util.Map do
  subject(:map) { java.util.HashMap.new(a: 1, b: nil) }

  it "implements #compact" do
    expect(map.compact).to eql(a: 1)
  end

  it "implements #compact!" do
    expect(map.compact!).to be map
    expect(map).to eq(a: 1)
  end

  it "implements #deconstruct_keys" do
    expect(map.deconstruct_keys).to be map
  end

  it "implements #except" do
    expect(map.except(:a)).to eql(b: nil)
  end

  it "implements #slice" do
    expect(map.slice(:a, :c)).to eql(a: 1)
  end

  it "implements #transform_keys" do
    expect(map.transform_keys(&:to_s)).to eql("a" => 1, "b" => nil)
    expect(map.transform_keys(a: :c, c: :d)).to eql(c: 1, b: nil)
    expect(map.transform_keys(a: :c, &:to_s)).to eql(:c => 1, "b" => nil)
    expect { map.transform_keys }.to raise_error(NotImplementedError)
  end

  describe "#transform_keys!" do
    it "implements with a block" do
      expect(map.transform_keys!(&:to_s)).to be map
      expect(map).to eq("a" => 1, "b" => nil)
    end

    it "implements with a hash" do
      expect(map.transform_keys!(a: :c, c: :d)).to be map
      expect(map).to eq(c: 1, b: nil)
    end

    it "implements with a block and a hash" do
      expect(map.transform_keys!(a: :c, &:to_s)).to be map
      expect(map).to eq(:c => 1, "b" => nil)
    end
  end

  it "implements #transform_values" do
    expect(map.transform_values(&:to_s)).to eql(a: "1", b: "")
  end

  it "implements #transform_values!" do
    expect(map.transform_values!(&:to_s)).to be map
    expect(map).to eq(a: "1", b: "")
  end
end
