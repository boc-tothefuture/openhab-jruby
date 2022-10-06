# frozen_string_literal: true

RSpec.describe 'OpenHAB::DSL::Rules::Triggers#channel_linked' do
  before do
    install_addon 'binding-astro'
    things.build { thing 'astro:sun:home', config: { 'geolocation' => '0,0' } }
  end

  it 'triggers' do
    linked_item = linked_thing = nil
    channel_linked do |event|
      linked_item = event.link.item
      linked_thing = event.link.channel_uid.thing
    end

    items.build { string_item 'StringItem1', channel: 'astro:sun:home:season#name' }

    expect(linked_item).to be StringItem1
    expect(linked_thing).to be things['astro:sun:home']
  end
end
