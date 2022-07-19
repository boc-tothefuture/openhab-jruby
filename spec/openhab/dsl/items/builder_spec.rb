# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::Builder do
  %i[color contact date_time dimmer group image location number player rollershutter string switch].each do |type|
    it "can create a #{type} item" do
      items.build { send(:"#{type}_item", 'MyItem', 'My Label') }
      expect(MyItem.label).to eql 'My Label'
      expect(MyItem).to be_a(Object.const_get(:"#{type.to_s.gsub(/(^[a-z]|_[a-z])/) do |x|
                                                    x.delete('_').capitalize
                                                  end }Item"))
    end
  end

  it 'can remove an item' do
    items.build { switch_item 'MySwitchItem' }
    items.remove(MySwitchItem)
    expect(items['MySwitchItem']).to be_nil
  end

  it 'can create items in a group' do
    items.build do
      group_item 'MyGroupItem' do
        switch_item 'MySwitchItem'
      end
    end

    expect(MyGroupItem.members.to_a).to eq [MySwitchItem]
    expect(MySwitchItem.groups).to eq [MyGroupItem]
  end

  it 'can add items to groups' do
    items.build do
      group_item 'MyGroupItem'
      switch_item 'MySwitchItem', groups: [MyGroupItem]
    end

    expect(MyGroupItem.members.to_a).to eq [MySwitchItem]
    expect(MySwitchItem.groups).to eq [MyGroupItem]
  end

  it 'can set a dimension on a number item' do
    items.build do
      number_item 'MyNumberItem', dimension: 'Power'
    end
    expect(MyNumberItem.dimension.ruby_class).to be javax.measure.quantity.Power
  end

  it 'can format a number item' do
    items.build do
      number_item 'MyNumberItem', format: 'something %d else'
    end

    MyNumberItem.update(1)
    expect(MyNumberItem.state_description.pattern).to eql 'something %d else'
  end

  it 'can set an icon' do
    items.build do
      switch_item 'MySwitch', :icon => :light
    end

    expect(MySwitch.category).to eql 'light'
  end

  it 'can add tags' do
    items.build do
      switch_item 'MySwitch', tags: ['MyTag', Semantics::Switch]
    end

    expect(MySwitch.tags).to match_array %w[MyTag Switch]
  end

  it 'can configure autoupdate' do
    items.build do
      switch_item 'MySwitch1', autoupdate: true
      switch_item 'MySwitch2', autoupdate: false
      switch_item 'MySwitch3'
    end

    expect(MySwitch1.meta['autoupdate']&.value).to eq 'true'
    expect(MySwitch2.meta['autoupdate']&.value).to eq 'false'
    expect(MySwitch3.meta['autoupdate']).to be_nil
  end

  it 'can configure expires' do
    items.build do
      switch_item 'MySwitch1', expire: 1.hour
      switch_item 'MySwitch2', expire: '2h'
      switch_item 'MySwitch3', expire: [3.hours, OFF]
      switch_item 'MySwitch4', expire: ['4h', { command: OFF }]
      string_item 'MyString', expire: [5.hours, 'EXPIRED']
    end

    expect(MySwitch1.meta['expire']&.value).to eq '1h'
    expect(MySwitch2.meta['expire']&.value).to eq '2h'
    expect(MySwitch3.meta['expire']&.value).to eq '3h,state=OFF'
    expect(MySwitch4.meta['expire']&.value).to eq '4h,command=OFF'
    expect(MyString.meta['expire']&.value).to eq "5h,state='EXPIRED'"
  end

  it 'passes homekit helper on to metadata' do
    items.build do
      switch_item 'MySwitch1', homekit: ['Switchable', { somethingElse: 'more' }]
    end

    expect(MySwitch1.meta['homekit']&.value).to eql 'Switchable'
    expect(MySwitch1.meta['homekit'].to_h).to eql({ somethingElse: 'more' })
  end

  it 'prefixes group members' do
    items.build do
      group_item 'MyGroup' do
        self.name_base = 'Family'
        self.label_base = 'Family Room '

        switch_item 'Lights_Switch', 'Lights'
        switch_item 'Lamps_Switch', 'Lamps'
      end
    end

    expect(FamilyLights_Switch.label).to eql 'Family Room Lights'
    expect(FamilyLamps_Switch.label).to eql 'Family Room Lamps'
  end

  it 'can create a group with a function and base type' do
    items.build do
      group_item 'MyGroup', :type => :switch, :function => 'OR(ON,OFF)'
    end

    expect(MyGroup.base_item).to be_a(SwitchItem)
    expect(MyGroup.function).to be_a(org.openhab.core.library.types.ArithmeticGroupFunction::Or)
    expect(MyGroup.function.parameters.to_a).to eql [ON, OFF]
  end

  it 'sets initial state' do
    items.build { number_item 'Number1', state: 1 }

    expect(Number1.state).to eq 1
  end

  it 'sets initial state on a switch with false' do
    items.build { switch_item 'Switch1', state: false }
    expect(Switch1.state).to be OFF
  end

  it 'sets initial state on a dimmer with an integer' do
    items.build { dimmer_item 'Dimmer1', state: 50 }
    expect(Dimmer1.state).to eq 50
  end

  it 'set initial state on a date time item with a string' do
    items.build { date_time_item 'DateTimeItem1', state: '1970-01-01T00:00:00+00:00' }
    expect(DateTimeItem1.state).to eq '1970-01-01T00:00:00+00:00'
  end
end
