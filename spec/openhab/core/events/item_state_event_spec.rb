# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Events::ItemStateEvent do
  it "has proper predicates for a NULL event" do
    event = org.openhab.core.items.events.ItemEventFactory.create_state_event("item", NULL)

    expect(event).to be_null
    expect(event).not_to be_undef
    expect(event.state?).to be false
    expect(event.state).to be_nil
  end

  it "has proper predicates for an UNDEF event" do
    event = org.openhab.core.items.events.ItemEventFactory.create_state_event("item", UNDEF)

    expect(event).not_to be_null
    expect(event).to be_undef
    expect(event.state?).to be false
    expect(event.state).to be_nil
  end

  it "has proper predicates for a ON event" do
    event = org.openhab.core.items.events.ItemEventFactory.create_state_event("item", ON)

    expect(event).not_to be_null
    expect(event).not_to be_undef
    expect(event.state?).to be true
    expect(event.state).to be ON
  end
end
