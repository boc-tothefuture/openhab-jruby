# frozen_string_literal: true

RSpec.describe 'OpenHAB::DSL::Rules::Triggers#trigger' do
  it 'supports an update using a generic trigger' do
    items.build { switch_item 'Switch1' }
    triggered = false
    rule 'execute rule when item is updated' do
      trigger 'core.ItemStateUpdateTrigger', itemName: 'Switch1'
      run { triggered = true }
    end
    Switch1.on
    expect(triggered).to be true
  end
end
