# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Rules::Builder do
  it "doesn't create a rule if there are no execution blocks" do
    rule(id: "test_rule") { on_start }

    expect($rules.get("test_rule")).to be_nil
    expect(spec_log_lines).to include(include("has no execution blocks, not creating rule"))
  end

  describe "triggers" do
    before do
      install_addon "binding-astro", ready_markers: "openhab.xmlThingTypes"
    end

    def self.test_thing_status_trigger(trigger, from: nil, to: nil, duration: nil, expect_triggered: true, &block)
      description = "supports status #{trigger} trigger"
      description += " from: #{from.inspect}" if from
      description += " to: #{to.inspect}" if to
      description += " for: #{duration.inspect}" if duration

      it description, caller: caller do
        # this is the only way to make this accessible to both
        # the rule where it's set, and to the block given to the
        # definition method
        @triggered = false

        class << self
          attr_writer :triggered

          def triggered?
            @triggered # rubocop:disable RSpec/InstanceVariable
          end
        end

        rule "Execute rule when thing is #{trigger}" do
          kwargs = { to: to }
          kwargs[:from] = from if from
          kwargs[:for] = duration if duration

          send(trigger, things["astro:sun:home"], **kwargs)
          run { self.triggered = true }
        end
        expect(thing.status.to_s).to eq "ONLINE"
        thing.disable
        expect(thing.status.to_s).to eq "UNINITIALIZED"
        if block
          instance_eval(&block)
        else
          expect(triggered?).to be expect_triggered
        end
      end
    end

    describe "#changed" do
      context "with items" do
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
          items.build { switch_item "Switch2", group: Switches }
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
              switch_item "Switch2", group: Switches
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
            items.build { contact_item "Contact3", group: Contacts }
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
                switch_item "Switch2", group: Switches
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

      context "with things" do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
        let!(:thing) do
          things.build { thing "astro:sun:home", config: { "geolocation" => "0,0" } }
        end

        test_thing_status_trigger(:changed)
        test_thing_status_trigger(:changed, to: :uninitialized)
        test_thing_status_trigger(:changed, to: :unknown, expect_triggered: false)
        test_thing_status_trigger(:changed, from: :online)
        test_thing_status_trigger(:changed, from: :unknown, expect_triggered: false)
        test_thing_status_trigger(:changed, from: :online, to: :uninitialized)
        test_thing_status_trigger(:changed, from: :unknown, to: :uninitialized, expect_triggered: false)
        test_thing_status_trigger(:changed, to: :uninitialized, duration: 10.seconds) do |_triggered|
          execute_timers
          expect(triggered?).to be false
          Timecop.travel(15.seconds)
          execute_timers
          expect(triggered?).to be true
        end
        test_thing_status_trigger(:changed, to: :uninitialized, duration: 20.seconds) do |_triggered|
          execute_timers
          expect(triggered?).to be false
          Timecop.travel(5.seconds)
          thing.enable
          execute_timers
          expect(triggered?).to be false
          Timecop.travel(20.seconds)
          execute_timers
          expect(triggered?).to be false
        end
      end
    end

    describe "#channel" do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
      before do
        things.build { thing "astro:sun:home", config: { "geolocation" => "0,0" } }
      end

      def self.test_channel_trigger(channel = nil, event: "", &block)
        description = "supports channel trigger "
        description += "on channel #{channel} " if channel
        description += "for event #{event} " unless event.empty?
        description += "with args #{block.source.sub(/.*(?:{|do)\s+\[(.*)\]\s+(?:}|end)/, '\\1')}"

        channel ||= "astro:sun:home:rise#event"
        it description, caller: caller do
          args = instance_exec(&block)
          triggered = false
          trigger = nil
          rule "Execute rule when channel is triggered" do
            channel(*args)
            run do |e|
              triggered = true
              trigger = e.event
            end
          end
          trigger_channel(channel, event)
          expect(triggered).to be true
          expect(trigger).to eql event
        end
      end

      test_channel_trigger { ["astro:sun:home:rise#event"] }
      test_channel_trigger { ["rise#event", { thing: "astro:sun:home" }] }
      test_channel_trigger { ["rise#event", { thing: things["astro:sun:home"] }] }
      test_channel_trigger { ["rise#event", { thing: things["astro:sun:home"].uid }] }
      test_channel_trigger { ["rise#event", { thing: [things["astro:sun:home"]] }] }
      test_channel_trigger { ["rise#event", { thing: [things["astro:sun:home"].uid] }] }
      test_channel_trigger { [things["astro:sun:home"].channels["rise#event"]] }
      test_channel_trigger { [things["astro:sun:home"].channels["rise#event"].uid] }
      test_channel_trigger { [[things["astro:sun:home"].channels["rise#event"]]] }
      test_channel_trigger { [[things["astro:sun:home"].channels["rise#event"].uid]] }

      test_channel_trigger(event: "START") { ["astro:sun:home:rise#event"] }

      test_channel_trigger("astro:sun:home:rise#event", event: "START") do
        [["rise#event", "set#event"], { thing: "astro:sun:home", triggered: %w[START STOP] }]
      end
      test_channel_trigger("astro:sun:home:set#event", event: "START") do
        [["rise#event", "set#event"], { thing: "astro:sun:home", triggered: %w[START STOP] }]
      end
      test_channel_trigger("astro:sun:home:rise#event", event: "STOP") do
        [["rise#event", "set#event"], { thing: "astro:sun:home", triggered: %w[START STOP] }]
      end
      test_channel_trigger("astro:sun:home:set#event", event: "STOP") do
        [["rise#event", "set#event"], { thing: "astro:sun:home", triggered: %w[START STOP] }]
      end
    end

    describe "#channel_linked" do
      before do
        things.build { thing "astro:sun:home", config: { "geolocation" => "0,0" } }
      end

      it "triggers" do
        linked_item = linked_thing = nil
        channel_linked do |event|
          linked_item = event.link.item
          linked_thing = event.link.channel_uid.thing
        end

        items.build { string_item "StringItem1", channel: "astro:sun:home:season#name" }

        expect(linked_item).to be StringItem1
        expect(linked_thing).to be things["astro:sun:home"]
      end
    end

    describe "#received_command" do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
      before do
        items.build do
          group_item "AlarmModes" do
            number_item "Alarm_Mode", state: 7
            number_item "Alarm_Mode_Other", state: 7
          end
        end
      end

      def self.test_command_trigger(item, members: false, command: nil, expect_triggered: true, &block)
        description = "receives command sent to #{item}"
        description += ".members" if members
        description += " with command #{command.inspect}" if command

        it description, caller: caller do
          triggered = false
          item = items[item]
          item = item.members if members
          rule "execute rule when item received command" do
            received_command item, command: command
            run { triggered = true }
          end
          instance_eval(&block)
          expect(triggered).to be expect_triggered
        end
      end

      test_command_trigger("Alarm_Mode") { Alarm_Mode << 7 }
      test_command_trigger("Alarm_Mode", command: 7) { Alarm_Mode << 7 }
      test_command_trigger("Alarm_Mode", command: 7, expect_triggered: false) { Alarm_Mode << 14 }
      test_command_trigger("Alarm_Mode", command: [7, 14]) { Alarm_Mode << 7 }
      test_command_trigger("Alarm_Mode", command: [7, 14]) { Alarm_Mode << 14 }
      test_command_trigger("Alarm_Mode", command: [7, 14], expect_triggered: false) { Alarm_Mode << 10 }
      test_command_trigger("Alarm_Mode", command: 8..10, expect_triggered: false) { Alarm_Mode << 7 }
      test_command_trigger("Alarm_Mode", command: 4..12) { Alarm_Mode << 7 }
      test_command_trigger("Alarm_Mode",
                           command: ->(t) { (8..10).cover?(t) },
                           expect_triggered: false) { Alarm_Mode << 7 }
      test_command_trigger("Alarm_Mode",
                           command: ->(t) { (4..12).cover?(t) }) { Alarm_Mode << 7 }
      test_command_trigger("Alarm_Mode",
                           command: proc { |t| (8..10).cover?(t) },
                           expect_triggered: false) { Alarm_Mode << 7 }
      test_command_trigger("Alarm_Mode",
                           command: proc { |t| (4..12).cover?(t) }) { Alarm_Mode << 7 }
      test_command_trigger("AlarmModes") { AlarmModes << 7 }
      test_command_trigger("AlarmModes", members: true) { Alarm_Mode << 7 }
      test_command_trigger("AlarmModes", members: true, command: [7, 14]) { Alarm_Mode << 7 }
      test_command_trigger("AlarmModes", members: true, command: [7, 14]) { Alarm_Mode << 14 }
      test_command_trigger("AlarmModes", members: true, command: [7, 14], expect_triggered: false) do
        Alarm_Mode << 10
      end
    end

    describe "#trigger" do
      it "supports an update using a generic trigger" do
        items.build { switch_item "Switch1" }
        triggered = false
        rule "execute rule when item is updated" do
          trigger "core.ItemStateUpdateTrigger", itemName: "Switch1"
          run { triggered = true }
        end
        Switch1.on
        expect(triggered).to be true
      end
    end

    describe "#thing_added" do
      it "triggers" do
        new_thing = nil
        thing_added do |event|
          new_thing = event.thing
        end

        things.build { thing "astro:sun:home", config: { "geolocation" => "0,0" } }

        expect(new_thing.uid).to eql "astro:sun:home"
      end
    end

    describe "#updated" do
      context "with things" do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
        let!(:thing) do # rubocop:disable RSpec/LetSetup
          things.build { thing "astro:sun:home", config: { "geolocation" => "0,0" } }
        end

        test_thing_status_trigger(:updated)
        test_thing_status_trigger(:updated, to: :uninitialized)
        test_thing_status_trigger(:updated, to: :unknown, expect_triggered: false)
      end
    end
  end

  describe "execution blocks" do
    describe "#run" do
      it "can call top level methods" do
        def outer_function
          logger.info("Outer function called")
        end
        rule do
          on_start
          run { outer_function }
        end
        expect(spec_log_lines).to include(include("Outer function called"))
      end

      it "logs errors" do
        rule do
          on_start
          run { raise "failure!" }
        end
        expect(spec_log_lines).to include(include("failure! (RuntimeError)"))
        expect(spec_log_lines).to include(match(%r{rules/builder_spec\.rb:(?:\d+):in `block}))
      end

      it "logs java exceptions" do
        rule do
          on_start
          run { java.lang.Integer.parse_int("k") }
        end
        expect(spec_log_lines).to include(include("Java::JavaLang::NumberFormatException"))
        expect(spec_log_lines).to include(match(/RUBY.*builder_spec\.rb/))
      end
    end

    # rubocop:disable RSpec/InstanceVariable
    context "with guards" do
      def run_rule
        rule do
          on_start
          run { @ran = :run }
          otherwise { @ran = :otherwise }
          only_if { @condition }
        end
      end

      it "executes run blocks if only_if is true" do
        @condition = true
        run_rule
        expect(@ran).to be :run
      end

      it "executes otherwise blocks if only_if is false" do
        @condition = false
        run_rule
        expect(@ran).to be :otherwise
      end
    end
    # rubocop:enable RSpec/InstanceVariable
  end

  describe "#description" do
    it "works" do
      rule id: "test_rule" do
        description "Rule Description"
        every :day
        run { nil }
      end
      expect($rules.get("test_rule").description).to eql "Rule Description"
    end
  end

  describe "#tags" do
    it "works" do
      rule id: "test_rule" do
        tags "tag1", "tag2", Semantics::LivingRoom
        every :day
        run { nil }
      end
      expect($rules.get("test_rule").tags).to match_array(%w[tag1 tag2 LivingRoom])
    end
  end
end
