# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Rules::Triggers::Changed do
  before do
    items.build do
      number_item "Alarm_Mode1"
      number_item "Alarm_Mode2"
      group_item "Switches", type: :switch, function: "OR(ON,OFF)" do
        switch_item "Switch1"
      end
    end
  end

  def self.test_changed_trigger(
    item = "Alarm_Mode1",
    initial_state: nil,
    new_state: 9,
    from: nil,
    to: nil,
    duration: nil,
    expect_triggered: true,
    caller: Kernel.caller,
    &block
  )
    description = "supports changed trigger on #{item}"
    description += " with initial state #{initial_state}" if initial_state
    description += " from: #{from.inspect}" if from
    description += " to: #{to.inspect}" if to
    description += " for: #{duration.inspect}" if duration

    it description, caller: caller do
      # this is the only way to make this accessible to both
      # the rule where it's set, and to the block given to the
      # definition method
      @triggered_item = nil

      class << self
        attr_accessor :triggered_item
      end

      trigger_items = eval("[#{item}]", nil, __FILE__, __LINE__) # rubocop:disable Security/Eval
      trigger_items.first.update(initial_state) if initial_state
      rule "Execute rule when item changes" do
        changed(*trigger_items, from: from, to: to, for: duration)
        run { |event| self.triggered_item = event.item.name }
      end
      if block
        instance_eval(&block)
      else
        item_to_update = items[expect_triggered] || trigger_items.first
        item_to_update.update(new_state)
        expect_triggered = item if expect_triggered == true
        expect(triggered_item).to eql expect_triggered
      end
    end
  end

  test_changed_trigger(to: 14, new_state: 14)
  test_changed_trigger(to: [10, 14], new_state: 10)
  test_changed_trigger(to: [10, 14], new_state: 7, expect_triggered: nil)
  test_changed_trigger(new_state: 7)
  test_changed_trigger("Switches", new_state: ON) do
    Switches.on
    expect(triggered_item).to eq "Switches"
  end
  test_changed_trigger("Switches.members", new_state: ON, expect_triggered: "Switch1")
  test_changed_trigger("Switches.members") do
    items.build { switch_item "Switch2", groups: [Switches] }
    Switch2.on
    expect(triggered_item).to eql "Switch2"
  end
  test_changed_trigger("Switch1", initial_state: OFF, new_state: OFF, expect_triggered: nil)
  test_changed_trigger("Switch1", initial_state: OFF, new_state: ON)
  test_changed_trigger("Switch1", initial_state: ON, new_state: ON, expect_triggered: nil)
  test_changed_trigger("Switch1", initial_state: ON, new_state: OFF)
  test_changed_trigger("Alarm_Mode1, Alarm_Mode2",
                       new_state: 3,
                       expect_triggered: "Alarm_Mode1")
  test_changed_trigger("Alarm_Mode1, Alarm_Mode2",
                       new_state: 4,
                       expect_triggered: "Alarm_Mode2")
  test_changed_trigger("[Alarm_Mode1, Alarm_Mode2]",
                       new_state: 3,
                       expect_triggered: "Alarm_Mode1")
  test_changed_trigger("[Alarm_Mode1, Alarm_Mode2]",
                       new_state: 4,
                       expect_triggered: "Alarm_Mode2")

  context "with a complicated item list" do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
    before do
      items.build do
        switch_item "Switch2", groups: [Switches]
        switch_item "Switch3"
        group_item "Contacts", type: :contact do
          contact_item "Contact1"
          contact_item "Contact2"
        end
      end
    end

    test_changed_trigger("Switches.members, [[Contacts.members], Switch3]",
                         new_state: "ON",
                         expect_triggered: "Switch1")
    test_changed_trigger("Switches.members, [[Contacts.members], Switch3]",
                         new_state: "ON",
                         expect_triggered: "Switch3")
    test_changed_trigger("Switches.members, [[Contacts.members], Switch3]") do
      items.build { contact_item "Contact3", groups: [Contacts] }
      Contact3.update(OPEN)
      expect(triggered_item).to eql "Contact3"
    end
  end

  test_changed_trigger(initial_state: 10, from: [10, 14], new_state: 11)
  test_changed_trigger(initial_state: 11,
                       from: [10, 14],
                       new_state: 12,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 14, from: [10, 14], new_state: 15)
  test_changed_trigger(initial_state: 10, from: 8..10, new_state: 14)
  test_changed_trigger(initial_state: 15,
                       from: 4..12,
                       new_state: 14,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4, to: 8..10)
  test_changed_trigger(initial_state: 11,
                       to: 4..12,
                       new_state: 14,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4, from: 2..5, to: 8..10)
  test_changed_trigger(initial_state: 4,
                       from: 5..6,
                       to: 8..10,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       from: 2..5,
                       to: 8..12,
                       new_state: 14,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4, to: 8..)
  test_changed_trigger(initial_state: 4,
                       to: 15..,
                       new_state: 14,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 10, from: ->(f) { f == 10 }) { Alarm_Mode1.update(14) }
  test_changed_trigger(initial_state: 15,
                       from: ->(f) { f == 10 },
                       new_state: 14,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 10, from: proc { |f| f == 10 }) { Alarm_Mode1.update(14) }
  test_changed_trigger(initial_state: 15,
                       from: proc { |f| f == 10 },
                       new_state: 14,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       to: ->(t) { t == 9 })
  test_changed_trigger(initial_state: 11,
                       to: ->(t) { t == 9 },
                       new_state: 14,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       to: proc { |t| t == 9 })
  test_changed_trigger(initial_state: 11,
                       to: proc { |t| t == 9 },
                       new_state: 14,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       from: ->(_f) { true },
                       to: ->(_t) { true })
  test_changed_trigger(initial_state: 4,
                       from: ->(_f) { false },
                       to: ->(_t) { true },
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       from: ->(_f) { true },
                       to: ->(_t) { false },
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       from: ->(_f) { false },
                       to: ->(_t) { false },
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       from: proc { true },
                       to: proc { true })
  test_changed_trigger(initial_state: 4,
                       from: proc { false },
                       to: proc { true },
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       from: proc { true },
                       to: proc { false },
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       from: proc { false },
                       to: proc { false },
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       from: proc { true },
                       to: 8..10)
  test_changed_trigger(initial_state: 4,
                       from: proc { true },
                       to: 8..10,
                       new_state: 14,
                       expect_triggered: nil)
  test_changed_trigger(initial_state: 4,
                       from: 4..10,
                       to: proc { true })
  test_changed_trigger(initial_state: 4,
                       from: 4,
                       to: proc { true })

  describe "duration" do
    before do
      items.build { number_item "Alarm_Delay", state: 5 }
    end

    def self.test_changed_trigger(item = "Alarm_Mode1",
                                  initial_state: 8,
                                  new_state: 14,
                                  duration: 5.seconds,
                                  expect_triggered: item,
                                  **kwargs,
                                  &block)
      block ||= proc do
        items[item].update(new_state)
        execute_timers
        expect(triggered_item).to be_nil
        Timecop.travel(10.seconds)
        execute_timers
        expect(triggered_item).to eql expect_triggered
      end

      super(item, initial_state: initial_state, duration: duration, caller: caller, **kwargs, &block)
    end

    test_changed_trigger
    # test_changed_trigger(duration: Alarm_Delay)
    test_changed_trigger(to: 14)
    test_changed_trigger(to: 14, new_state: 10, expect_triggered: nil)
    test_changed_trigger(from: 8, to: 14)
    test_changed_trigger(from: 10, to: 14, new_state: 10, expect_triggered: nil)
    test_changed_trigger(to: [10, 14])
    test_changed_trigger(from: [8, 10], to: 14)
    test_changed_trigger(from: [8, 10], to: [11, 14])
    test_changed_trigger(from: [8, 10], to: [11, 14], new_state: 12, expect_triggered: nil)
    test_changed_trigger(from: [8, 10], to: [9, 10], expect_triggered: nil)
    test_changed_trigger(duration: 10.seconds) do
      Alarm_Mode1.update(14)
      execute_timers
      expect(triggered_item).to be_nil
      Timecop.travel(5.seconds)
      execute_timers
      expect(triggered_item).to be_nil
      Alarm_Mode1.update(10)
      execute_timers
      expect(triggered_item).to be_nil
      Timecop.travel(30.seconds)
      execute_timers
      expect(triggered_item).to eql "Alarm_Mode1"
    end
    test_changed_trigger(to: 14, duration: 10.seconds) do
      Alarm_Mode1.update(14)
      execute_timers
      expect(triggered_item).to be_nil
      Timecop.travel(5.seconds)
      execute_timers
      expect(triggered_item).to be_nil
      Alarm_Mode1.update(10)
      execute_timers
      expect(triggered_item).to be_nil
      Timecop.travel(20.seconds)
      execute_timers
      expect(triggered_item).to be_nil
    end

    context "with a numeric group item" do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
      before do
        items.build do
          group_item "Modes" do
            number_item "Alarm_Mode3", state: 0
            number_item "Alarm_Mode4"
          end
        end
      end

      def self.test_changed_trigger(item, new_state: 14, expect_triggered: "Alarm_Mode4", **kwargs)
        super(item, caller: caller, **kwargs) do
          Alarm_Mode4.update(new_state)
          execute_timers
          expect(triggered_item).to be_nil
          Timecop.travel(3.seconds)
          execute_timers
          expect(triggered_item).to be_nil
          Timecop.travel(5.seconds)
          execute_timers
          expect(triggered_item).to eql expect_triggered
        end
      end
      test_changed_trigger("Modes.members")
      test_changed_trigger("Modes.members", to: 14)
      test_changed_trigger("Modes.members", to: 14, new_state: 10, expect_triggered: nil)
      test_changed_trigger("Modes.members", from: 8, to: 14)
      test_changed_trigger("Modes.members", from: 10, to: 14, new_state: 10, expect_triggered: nil)
    end

    context "with a switch group item" do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
      before do
        items.build do
          switch_item "Switch2", groups: [Switches]
        end
        Switch1.off
      end

      def self.test_changed_trigger(item,
                                    initial_state: OFF,
                                    new_state: ON,
                                    expect_triggered: "Switches",
                                    **kwargs)
        super(item, initial_state: initial_state, caller: caller, **kwargs) do
          Switch2.update(new_state)
          execute_timers
          expect(triggered_item).to be_nil
          Timecop.travel(3.seconds)
          execute_timers
          expect(triggered_item).to be_nil
          Timecop.travel(5.seconds)
          execute_timers
          expect(triggered_item).to eql expect_triggered
        end
      end
      test_changed_trigger("Switches")
      test_changed_trigger("Switches", to: ON)
      test_changed_trigger("Switches", to: ON, initial_state: ON, new_state: OFF, expect_triggered: nil)
      test_changed_trigger("Switches", from: OFF, to: ON)
      test_changed_trigger("Switches", from: ON, to: ON, expect_triggered: nil)
    end
  end
end
