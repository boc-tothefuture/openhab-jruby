# frozen_string_literal: true

# rubocop:disable RSpec/IdenticalEqualityAssertion
RSpec.describe OpenHAB::Core::Items::Proxy do
  before do
    items.build { switch_item "Switch1" }
  end

  self.consistent_proxies = false

  it "gives a new instance every time it's accessed" do
    expect(Switch1).not_to be Switch1
    expect(Switch1).to eql Switch1
    expect(Switch1.__getobj__).to be Switch1.__getobj__
    expect(Switch1.hash).to eql Switch1.hash
  end

  it "can be used in a Java map" do
    map = java.util.concurrent.ConcurrentHashMap.new
    map.put(Switch1, 1)
    expect(map.get(Switch1)).to be 1
  end

  it "can be used in a Hash" do
    hash = {}
    hash[Switch1] = 1
    expect(hash[Switch1]).to be 1
  end

  it "can be used in a Set" do
    set = Set.new
    set << Switch1
    expect(set).to include(Switch1)
  end

  it "still works with replaced items" do
    original = Switch1

    items.remove("Switch1")
    expect { Switch1 }.to raise_error(NameError)

    items.build { switch_item "Switch1" }

    new_item = Switch1
    # new instance
    expect(original).not_to be new_item
    # but it now refers to the same underlying item
    expect(original.__getobj__).to be new_item.__getobj__
  end

  describe "Comparisons" do
    before do
      items.build { switch_item "Switch2" }
    end

    it "can be done with ==" do
      expect(Switch1).to eq Switch1
      expect(Switch1).not_to eq Switch2
    end

    it "can be done with !=" do
      expect(Switch1 != Switch2).to be true
      expect(Switch1 != Switch1).to be false # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    end
  end
end
# rubocop:enable RSpec/IdenticalEqualityAssertion
