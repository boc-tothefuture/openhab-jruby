# frozen_string_literal: true

RSpec.describe "OpenHAB::DSL::Rules::Triggers#thing_added" do
  before do
    install_addon "binding-astro"
  end

  it "triggers" do
    new_thing = nil
    thing_added do |event|
      new_thing = event.thing
    end

    things.build { thing "astro:sun:home", config: { "geolocation" => "0,0" } }

    expect(new_thing.uid).to eql "astro:sun:home"
  end
end
