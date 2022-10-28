# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Items::ContactItem do
  subject(:item) do
    items.build do
      contact_item "ContactOne", "Contact One"
    end
  end

  it "supports open?/closed? predicates" do
    item.update(OPEN)
    expect(item).to be_open
    item.update(CLOSED)
    expect(item).to be_closed
  end

  it "can be selected with grep" do
    items.build do
      contact_item "ContactTwo"
      dimmer_item "Dimmer"
    end

    expect(items.grep(ContactItem)).to eq [ContactTwo]
  end
end
