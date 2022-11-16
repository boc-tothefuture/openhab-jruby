# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Events::ItemStateChangedEvent do
  it "has proper predicates for an ON => NULL event" do
    event = org.openhab.core.items.events.ItemEventFactory.create_state_changed_event("item", NULL, ON)

    expect(event).to be_null
    expect(event).not_to be_undef
    expect(event.state?).to be false
    expect(event.state).to be_nil
    expect(event.was_null?).to be false
    expect(event.was_undef?).to be false
    expect(event.was?).to be true
    expect(event.was).to be ON
  end

  it "has proper predicates for an ON => UNDEF event" do
    event = org.openhab.core.items.events.ItemEventFactory.create_state_changed_event("item", UNDEF, ON)

    expect(event).not_to be_null
    expect(event).to be_undef
    expect(event.state?).to be false
    expect(event.state).to be_nil
    expect(event.was_null?).to be false
    expect(event.was_undef?).to be false
    expect(event.was?).to be true
    expect(event.was).to be ON
  end

  it "has proper predicates for a NULL => ON event" do
    event = org.openhab.core.items.events.ItemEventFactory.create_state_changed_event("item", ON, NULL)

    expect(event).not_to be_null
    expect(event).not_to be_undef
    expect(event.state?).to be true
    expect(event.state).to be ON
    expect(event.was_null?).to be true
    expect(event.was_undef?).to be false
    expect(event.was?).to be false
    expect(event.was).to be_nil
  end

  it "has proper predicates for an UNDEF => ON event" do
    event = org.openhab.core.items.events.ItemEventFactory.create_state_changed_event("item", ON, UNDEF)

    expect(event).not_to be_null
    expect(event).not_to be_undef
    expect(event.state?).to be true
    expect(event.state).to be ON
    expect(event.was_null?).to be false
    expect(event.was_undef?).to be true
    expect(event.was?).to be false
    expect(event.was).to be_nil
  end
end
