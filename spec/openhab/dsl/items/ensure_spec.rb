# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::Ensure do
  let(:triggers) { [] }
  let(:all_items_group) { items.build { group_item "AllItems" } }
  let(:item) { items.build { dimmer_item "DimmerOne", group: AllItems } }
  let(:group) do
    items.build do
      group_item "Dimmers", type: :dimmer, function: :avg do
        dimmer_item "Dimmer1", group: AllItems
        dimmer_item "Dimmer2", group: AllItems
      end
    end
  end
  let(:both) { %i[received_command updated].freeze }
  let(:all) { %i[received_command received_command updated updated].freeze }

  before do
    received_command all_items_group.members do
      triggers << :received_command
    end
    updated all_items_group.members do
      triggers << :updated
    end
  end

  def check_command(initial, final = initial, *expected_triggers)
    item.update(initial)
    triggers.clear
    yield
    expect(item.state).to eq final
    expect(triggers).to match_array(expected_triggers)
  end

  describe "#ensure" do
    it "sends commands if not in a given state" do
      check_command(0, 100, *both) { item.ensure.on }
      check_command(0, 100, *both) { item.ensure << ON }
      check_command(0, 100, :updated) { item.ensure.update(ON) }
      check_command(0, 50, *both) { item.ensure << 50 }
      check_command(0, 50, :updated) { item.ensure.update(50) }

      check_command(50, 0, *both) { item.ensure.off }
      check_command(50, 0, *both) { item.ensure << OFF }
      check_command(50, 0, :updated) { item.ensure.update(OFF) }
      check_command(50, 100, *both) { item.ensure << 100 }
      check_command(50, 100, :updated) { item.ensure.update(100) }

      check_command(100, 0, *both) { item.ensure.off }
      check_command(100, 0, *both) { item.ensure << OFF }
      check_command(100, 0, :updated) { item.ensure.update(OFF) }
      check_command(100, 0, *both) { item.ensure << 0 }
      check_command(100, 0, :updated) { item.ensure.update(0) }
    end

    it "does not send command if already in a given state" do
      check_command(0) { item.ensure.off }
      check_command(0) { item.ensure << OFF }
      check_command(0) { item.ensure << 0 }
      check_command(0) { item.ensure.update(OFF) }
      check_command(0) { item.ensure.update(0) }

      check_command(50) { item.ensure.on }
      check_command(50) { item.ensure << ON }
      check_command(50) { item.ensure << 50 }
      check_command(50) { item.ensure.update(50) }

      check_command(100) { item.ensure.on }
      check_command(100) { item.ensure << ON }
      check_command(100) { item.ensure << 100 }
      check_command(100) { item.ensure.update(100) }
    end

    def check_group_command(initial1, initial2, final1 = initial1, final2 = initial2, *expected_triggers)
      group
      Dimmer1.update(initial1)
      Dimmer2.update(initial2)
      triggers.clear
      yield
      expect(Dimmer1.state).to eq final1
      expect(Dimmer2.state).to eq final2
      expect(triggers).to match_array(expected_triggers)
    end

    it "sends commands to group if not in a given state" do
      check_group_command(0, 0, 100, 100, *all) { group.ensure.on }
      check_group_command(0, 0, 100, 100, *all) { group.ensure << ON }
      check_group_command(0, 0, 50, 50, *all) { group.ensure << 50 }

      check_group_command(50, 0, 0, 0, *all) { group.ensure.off }
      check_group_command(50, 0, 0, 0, *all) { group.ensure << OFF }
      check_group_command(50, 0, 100, 100, *all) { group.ensure << 100 }
    end

    it "doesn't send commands to group if in a given state" do
      check_group_command(0, 0) { group.ensure.off }
      check_group_command(0, 0) { group.ensure << OFF }
      check_group_command(100, 0) { group.ensure << 50 }
    end

    it "sends commands memberwise to group if not in given state" do
      check_group_command(0, 100, 100, 100, *both) { group.members.ensure.on }
      check_group_command(0, 100, 100, 100, *both) { group.members.ensure.command(ON) }
      check_group_command(0, 100, 50, 50, *all) { group.members.ensure.command(50) }
    end

    it "works with boolean commands" do
      check_command(0) { item.ensure << false }
      check_command(100) { item.ensure << true }
      check_command(0, 100, *both) { item.ensure << true }
      check_command(100, 0, *both) { item.ensure << false }
    end

    it "is available on Enumerable" do
      items = group.members.to_a
      check_group_command(50, 50) { items.ensure.command(50) }
      check_group_command(50, 50, 10, 10, *all) { items.ensure.command(10) }
    end

    it "can send a plain number to a NumberItem with a quantity" do
      items.build { number_item "Temp", dimension: "Temperature", format: "%d °F", group: AllItems }
      Temp.update(80)
      expect(Temp.state).to eq 80 | "°F"
      triggers.clear
      Temp.ensure << 80
      expect(triggers).to be_empty
      Temp.ensure << 50
      expect(Temp.state).to eq 50 | "°F"
      expect(Temp.state).to eq 10 | "°C"
      expect(triggers).to match_array(both)
      triggers.clear
      Temp.ensure << (10 | "°C")
      expect(triggers).to be_empty
    end
  end

  describe "#ensure_states" do
    it "applies to all commands inside the block" do
      check_command(0) do
        ensure_states do
          item.off
        end
      end

      check_command(0) do
        ensure_states do
          item.update(OFF)
        end
      end

      check_command(0, 100, *both) do
        ensure_states do
          item.on
        end
      end

      check_command(0, 100, :updated) do
        ensure_states do
          item.update(ON)
        end
      end
    end
  end
end
