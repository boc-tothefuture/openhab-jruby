# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Items::GroupItem do
  before do
    items.build do
      group_item "Sensors" do
        group_item "Temperatures"
      end

      group_item "House" do
        group_item "GroundFloor" do
          group_item "LivingRoom" do
            number_item "LivingRoom_Temp", "Living Room Temperature", state: 70, groups: [Temperatures]
          end
          number_item "Bedroom_Temp", "Bedroom Temperature", state: 50, groups: [Temperatures]
          number_item "Den_Temp", "Den Temperature", state: 30, groups: [Temperatures]
        end
      end
    end
  end

  describe "#members" do
    it "is enumerable" do
      expect(Temperatures.members.count).to be 3
      expect(Temperatures.members.map(&:label)).to match_array ["Bedroom Temperature", "Den Temperature",
                                                                "Living Room Temperature"]
    end

    it "does math" do
      expect(Temperatures.members.map(&:state).max).to eq 70
      expect(Temperatures.members.map(&:state).min).to eq 30
    end

    it "is a live view" do
      expect(Temperatures.members.map(&:name)).to match_array %w[Bedroom_Temp Den_Temp LivingRoom_Temp]
      items.build do
        number_item "Kitchen_Temp", groups: [Temperatures]
        number_item "Basement_Temp"
      end
      expect(Temperatures.members.map(&:name)).to match_array %w[Bedroom_Temp Den_Temp Kitchen_Temp
                                                                 LivingRoom_Temp]
    end

    it "can be added to an array" do
      expect([Temperatures] + LivingRoom.members).to match_array [Temperatures, LivingRoom_Temp]
      expect(LivingRoom.members + [Temperatures]).to match_array [Temperatures, LivingRoom_Temp]
      expect(LivingRoom.members + GroundFloor.members).to match_array [LivingRoom_Temp, Bedroom_Temp, Den_Temp,
                                                                       LivingRoom]
    end
  end

  describe "#all_members" do
    it "is enumerable" do
      expect(House.all_members.count).to be 3
      expect(House.all_members.map(&:label)).to match_array [
        "Bedroom Temperature",
        "Den Temperature",
        "Living Room Temperature"
      ]
    end
  end

  describe "#command" do
    it "propagates to all items" do
      GroundFloor.command(60)
      expect(Bedroom_Temp.state).to eq 60
      expect(Den_Temp.state).to eq 60
    end
  end

  describe "#method_missing" do
    it "has command methods for the group type" do
      items.build do
        group_item "Switches", type: :switch
      end
      Switches.on
    end
  end

  describe "#inspect" do
    it "includes the base type" do
      items.build do
        group_item "Switches", type: :switch
      end
      expect(Switches.inspect).to eql "#<OpenHAB::Core::Items::GroupItem:Switch nil state=NULL>"
    end

    it "includes the function" do
      items.build do
        group_item "Switches", type: :switch, function: "OR(ON,OFF)"
      end
      expect(Switches.inspect).to eql "#<OpenHAB::Core::Items::GroupItem:Switch:OR(ON,OFF) nil state=NULL>"
    end
  end
end
