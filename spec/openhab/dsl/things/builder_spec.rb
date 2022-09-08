# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Things::Builder do
  before { install_addon 'binding-astro' }

  it 'can create a thing' do
    things.build do
      thing 'astro:sun:home', 'Astro Sun Data', config: { 'geolocation' => '0,0' }
    end
    expect(home = things['astro:sun:home']).not_to be_nil
    expect(home.channels['rise#event']).not_to be_nil
    expect(home.configuration.get('geolocation')).to eq '0,0'
  end

  it 'can create a thing with separate binding and type params' do
    things.build do
      thing 'home', 'Astro Sun Data', binding: 'astro', type: 'sun'
    end
    expect(things['astro:sun:home']).not_to be_nil
  end
end
