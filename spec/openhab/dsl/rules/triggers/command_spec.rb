# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Rules::Triggers::Command do
  describe 'received_command triggers' do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
    before do
      items.build do
        group_item 'AlarmModes' do
          number_item 'Alarm_Mode', state: 7
          number_item 'Alarm_Mode_Other', state: 7
        end
      end
    end

    def self.test_command_trigger(item, members: false, command: nil, expect_triggered: true, &block) # rubocop:disable Metrics
      description = "receives command sent to #{item}"
      description += '.members' if members
      description += " with command #{command.inspect}" if command

      it description, caller: caller do
        triggered = false
        item = items[item]
        item = item.members if members
        rule 'execute rule when item received command' do
          received_command item, command: command
          run { triggered = true }
        end
        instance_eval(&block)
        expect(triggered).to be expect_triggered
      end
    end

    test_command_trigger('Alarm_Mode') { Alarm_Mode << 7 }
    test_command_trigger('Alarm_Mode', command: 7) { Alarm_Mode << 7 }
    test_command_trigger('Alarm_Mode', command: 7, expect_triggered: false) { Alarm_Mode << 14 }
    test_command_trigger('Alarm_Mode', command: [7, 14]) { Alarm_Mode << 7 }
    test_command_trigger('Alarm_Mode', command: [7, 14]) { Alarm_Mode << 14 }
    test_command_trigger('Alarm_Mode', command: [7, 14], expect_triggered: false) { Alarm_Mode << 10 }
    test_command_trigger('Alarm_Mode', command: 8..10, expect_triggered: false) { Alarm_Mode << 7 }
    test_command_trigger('Alarm_Mode', command: 4..12) { Alarm_Mode << 7 }
    test_command_trigger('Alarm_Mode',
                         command: ->(t) { (8..10).cover?(t) },
                         expect_triggered: false) { Alarm_Mode << 7 }
    test_command_trigger('Alarm_Mode',
                         command: ->(t) { (4..12).cover?(t) }) { Alarm_Mode << 7 }
    test_command_trigger('Alarm_Mode',
                         command: proc { |t| (8..10).cover?(t) },
                         expect_triggered: false) { Alarm_Mode << 7 }
    test_command_trigger('Alarm_Mode',
                         command: proc { |t| (4..12).cover?(t) }) { Alarm_Mode << 7 }
    test_command_trigger('AlarmModes') { AlarmModes << 7 }
    test_command_trigger('AlarmModes', members: true) { Alarm_Mode << 7 }
    test_command_trigger('AlarmModes', members: true, command: [7, 14]) { Alarm_Mode << 7 }
    test_command_trigger('AlarmModes', members: true, command: [7, 14]) { Alarm_Mode << 14 }
    test_command_trigger('AlarmModes', members: true, command: [7, 14], expect_triggered: false) { Alarm_Mode << 10 }
  end

  describe 'helper predicates' do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
    before do
      stub_const('PREDICATES',
                 %i[refresh?
                    on?
                    off?
                    increase?
                    decrease?
                    up?
                    down?
                    stop?
                    move?
                    play?
                    pause?
                    rewind?
                    fast_forward?
                    next?
                    previous?].freeze)
    end

    def self.test_command_predicate(item_type, command) # rubocop:disable Metrics
      it "has a predicate for #{command}" do
        items.build { item(item_type, 'TestItem') }
        predicate_method = PREDICATES.find { |pr| pr.to_s[0..3].delete('?').upcase == command[0..3] }
        triggered = false
        rule 'execute rule when item received command' do
          received_command TestItem
          run do |event|
            expect(event.send(predicate_method)).to be true
            other_predicates = PREDICATES - [predicate_method]
            expect(other_predicates.map { |pr| event.send(pr) }).to all(be false)
            triggered = true
          end
        end
        TestItem << Object.const_get(command)
        expect(triggered).to be true
      end
    end

    test_command_predicate(:switch, 'REFRESH')
    test_command_predicate(:switch, 'ON')
    test_command_predicate(:switch, 'OFF')
    test_command_predicate(:dimmer, 'INCREASE')
    test_command_predicate(:dimmer, 'DECREASE')
    test_command_predicate(:rollershutter, 'UP')
    test_command_predicate(:rollershutter, 'DOWN')
    test_command_predicate(:rollershutter, 'STOP')
    test_command_predicate(:rollershutter, 'MOVE')
    test_command_predicate(:player, 'PLAY')
    test_command_predicate(:player, 'PAUSE')
    test_command_predicate(:player, 'REWIND')
    test_command_predicate(:player, 'FASTFORWARD')
    test_command_predicate(:player, 'NEXT')
    test_command_predicate(:player, 'PREVIOUS')
  end
end
