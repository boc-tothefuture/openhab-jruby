# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::RollershutterItem do
  subject(:item) { RollerOne }

  before do
    items.build do
      group_item "Rollershutters" do
        rollershutter_item "RollerOne", state: 50
        rollershutter_item "RollerTwo", state: 70
      end
    end
  end

  describe "sending command using PercentType" do
    specify { expect((item << 70).state).to eq 70 }
    specify { expect((RollerOne << RollerTwo).state).to eq 70 }
    specify { expect((item << PercentType.new(10)).state).to eq 10 }
  end

  describe "command methods" do
    specify { expect(item.up.state).to eq 0 }
    specify { expect(item.down.state).to eq 100 }

    %i[stop move].each do |method|
      it "sends #{method} command as a method" do
        received = nil
        received_command item do |event|
          received = event.command
        end

        item.send(method)
        expect(received.to_s).to eql method.to_s.upcase
      end
    end
  end

  describe "state predicates" do
    specify { expect(item).not_to be_up }
    specify { expect(item).not_to be_down }
    specify { expect(item.update(0)).to be_up }
    specify { expect(item.update(0)).not_to be_down }
    specify { expect(item.update(100)).not_to be_up }
    specify { expect(item.update(100)).to be_down }
  end

  describe "math operations" do
    specify { expect(item + 20).to eq 70 }
    specify { expect(item - 20).to eq 30 }
    specify { expect(item * 2).to eq 100 }
    specify { expect(item / 2).to eq 25 }
    specify { expect(20 + item).to eq 70 }
    specify { expect(90 - item).to eq 40 }
    specify { expect(2 * item).to eq 100 }
    specify { expect(100 / item).to eq 2 }
    specify { expect(70 % item).to eq 20 }
  end

  it "works in case statements" do
    { 0 => UP,
      100 => DOWN,
      25 => "1..50",
      NULL => NULL }.each do |initial, result|
        item.update(initial)
        expect(case item
               when 0 then UP
               when 100 then DOWN
               when 51...100 then "51...100"
               when 1..50 then "1..50"
               else
                 NULL
               end).to eql result
      end
  end
end
