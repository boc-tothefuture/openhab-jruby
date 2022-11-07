# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Items::Semantics do
  before do
    items.build do
      group_item "gMyGroup"
      group_item "gOutdoor", tags: [Semantics::Outdoor] do
        group_item "gPatio", tags: [Semantics::Patio] do
          group_item "Patio_Light_Bulb", tags: [Semantics::Lightbulb] do
            dimmer_item "Patio_Light_Brightness", tags: [Semantics::Control, Semantics::Level]
            color_item "Patio_Light_Color", tags: [Semantics::Control, Semantics::Light]
          end

          switch_item "Patio_Motion", tags: [Semantics::MotionDetector, "CustomTag"]
          switch_item "Patio_Point", tags: [Semantics::Control]
        end
      end
      group_item "gIndoor", tags: [Semantics::Indoor] do
        group_item "gLivingRoom", tags: [Semantics::LivingRoom] do
          group_item "LivingRoom_Light1_Bulb", groups: [gMyGroup], tags: [Semantics::Lightbulb] do
            dimmer_item "LivingRoom_Light1_Brightness", tags: [Semantics::Control, Semantics::Level]
            color_item "LivingRoom_Light1_Color", tags: [Semantics::Control, Semantics::Light]
            switch_item "LivingRoom_Light1_Custom", groups: [gMyGroup]
          end
          group_item "LivingRoom_Light2_Bulb", tags: [Semantics::Lightbulb, "CustomTag"] do
            dimmer_item "LivingRoom_Light2_Brightness", tags: [Semantics::Control, Semantics::Level]
            color_item "LivingRoom_LIght2_Color", tags: [Semantics::Control, Semantics::Light]
          end
          switch_item "LivingRoom_Motion", tags: [Semantics::MotionDetector]
        end
      end
      switch_item "NoSemantic"
    end
  end

  describe "provides semantic predicates" do
    specify { expect(gIndoor).to be_location }
    specify { expect(gIndoor).not_to be_equipment }
    specify { expect(gIndoor).not_to be_point }
    specify { expect(NoSemantic).not_to be_semantic }
    specify { expect(Patio_Light_Bulb).to be_semantic }
    specify { expect(Patio_Light_Bulb).to be_equipment }
    specify { expect(Patio_Motion).to be_equipment }
  end

  describe "semantic types methods" do
    specify { expect(Patio_Light_Bulb.location_type).to be Semantics::Patio }
    specify { expect(Patio_Light_Bulb.equipment_type).to be Semantics::Lightbulb }
    specify { expect(Patio_Light_Brightness.point_type).to be Semantics::Control }
    specify { expect(Patio_Light_Brightness.property_type).to be Semantics::Level }
    specify { expect(Patio_Light_Brightness.equipment_type).to be Semantics::Lightbulb }
    specify { expect(Patio_Light_Brightness.semantic_type).to be Semantics::Control }
  end

  describe "related semantic item methods" do
    specify { expect(Patio_Light_Bulb.location).to be gPatio }
    specify { expect(Patio_Light_Brightness.location).to be gPatio }
    specify { expect(Patio_Light_Brightness.equipment).to be Patio_Light_Bulb }
  end

  describe "#points" do
    it "returns siblings of a point" do
      expect(Patio_Light_Brightness.points).to eql [Patio_Light_Color]
    end

    describe "returns points of an equipment" do
      specify { expect(Patio_Light_Bulb.points).to match_array([Patio_Light_Brightness, Patio_Light_Color]) }
      specify { expect(Patio_Light_Bulb.points(Semantics::Light)).to eql [Patio_Light_Color] }
      specify { expect(Patio_Light_Bulb.points(Semantics::Level)).to eql [Patio_Light_Brightness] }
      specify { expect(Patio_Light_Bulb.points(Semantics::Level, Semantics::Control)).to eql [Patio_Light_Brightness] }
    end

    it "returns points of a location" do
      expect(gPatio.points).to eql [Patio_Point]
    end

    it "does not return points in sublocations and equipments" do
      items.build do
        group_item "Outdoor_Light_Bulb", groups: [gOutdoor], tags: [Semantics::Lightbulb] do
          switch_item "Outdoor_Light_Switch", tags: [Semantics::Control, Semantics::Power]
        end
        switch_item "Outdoor_Point", tags: [Semantics::Control], groups: [gOutdoor]
      end

      expect(gOutdoor.points).to eql [Outdoor_Point]
    end

    context "with invalid arguments" do
      specify { expect { Patio_Light_Bulb.points(:not_a_class) }.to raise_error(ArgumentError) }
      specify { expect { Patio_Light_Bulb.points(Semantics::Level, Semantics::Indoor) }.to raise_error(ArgumentError) }
      specify { expect { Patio_Light_Bulb.points(Semantics::Lightbulb) }.to raise_error(ArgumentError) }
      specify { expect { Patio_Light_Bulb.points(Semantics::Indoor) }.to raise_error(ArgumentError) }
      specify { expect { Patio_Light_Bulb.points(Semantics::Level, Semantics::Light) }.to raise_error(ArgumentError) }

      specify do
        expect do
          Patio_Light_Bulb.points(Semantics::Switch, Semantics::Control)
        end.to raise_error(ArgumentError)
      end

      specify do
        expect do
          Patio_Light_Bulb.points(Semantics::Switch, Semantics::Light, Semantics::Level)
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe ::Enumerable do
    describe "provides semantic methods" do
      specify { expect(gPatio.equipments).to match_array([Patio_Light_Bulb, Patio_Motion]) }
      specify { expect(gIndoor.locations).to eql [gLivingRoom] }
      specify { expect(gIndoor.locations(Semantics::Room)).to eql [gLivingRoom] }
      specify { expect(gIndoor.locations(Semantics::LivingRoom)).to eql [gLivingRoom] }
      specify { expect(gIndoor.locations(Semantics::FamilyRoom)).to eql [] }
      specify { expect { gIndoor.locations(Semantics::Light) }.to raise_error(ArgumentError) }
      specify { expect(items.tagged("CustomTag")).to match_array([LivingRoom_Light2_Bulb, Patio_Motion]) }

      specify do
        expect(gLivingRoom.members.tagged("Lightbulb")).to match_array([LivingRoom_Light1_Bulb, LivingRoom_Light2_Bulb])
      end

      specify { expect(gLivingRoom.members.not_tagged("Lightbulb")).to eql [LivingRoom_Motion] }
      specify { expect(gLivingRoom.members.member_of(gMyGroup)).to eql [LivingRoom_Light1_Bulb] }

      specify do
        expect(gLivingRoom.members.not_member_of(gMyGroup)).to match_array([LivingRoom_Light2_Bulb, LivingRoom_Motion])
      end

      specify do
        expect(LivingRoom_Motion.location.members.not_member_of(gMyGroup).tagged("CustomTag"))
          .to eql [LivingRoom_Light2_Bulb]
      end

      specify { expect(LivingRoom_Motion.location.equipments.tagged("CustomTag")).to eql [LivingRoom_Light2_Bulb] }
      specify { expect(gLivingRoom.equipments.members.member_of(gMyGroup)).to eql [LivingRoom_Light1_Custom] }
    end

    describe "#command" do
      it "works" do
        triggered = false
        received_command(LivingRoom_Light1_Brightness) { triggered = true }
        [LivingRoom_Light1_Brightness].on
        expect(triggered).to be true
        expect(LivingRoom_Light1_Brightness).to be_on
      end
    end

    describe "#update" do
      it "works" do
        triggered = false
        changed(LivingRoom_Light1_Brightness) { triggered = true }
        [LivingRoom_Light1_Brightness].update(ON)
        expect(triggered).to be true
        expect(LivingRoom_Light1_Brightness).to be_on
      end
    end

    describe "#points" do
      def points(*args)
        gPatio.members.equipments.members.points(*args)
      end

      specify { expect(points).to match_array([Patio_Light_Brightness, Patio_Light_Color]) }
      specify { expect(points(Semantics::Control)).to match_array([Patio_Light_Brightness, Patio_Light_Color]) }
      specify { expect(points(Semantics::Light)).to eql([Patio_Light_Color]) }
      specify { expect(points(Semantics::Light, Semantics::Control)).to eql([Patio_Light_Color]) }

      specify { expect { points(Semantics::Light, Semantics::Level) }.to raise_error(ArgumentError) }
      specify { expect { points(Semantics::Room) }.to raise_error(ArgumentError) }
      specify { expect { points(Semantics::Control, Semantics::Switch) }.to raise_error(ArgumentError) }

      context "with GroupItem as a point" do
        before do
          items.build do
            group_item "My_Equipment", groups: [gIndoor], tags: [Semantics::Lightbulb] do
              group_item "GroupPoint", tags: [Semantics::Switch]
              dimmer_item "Brightness", tags: [Semantics::Control, Semantics::Level]
            end
          end
        end

        it "works" do
          expect(gIndoor.equipments.members.points).to match_array([Brightness, GroupPoint])
        end

        it "can find its siblings" do
          items.build do
            switch_item "MySwitch", groups: [My_Equipment], tags: [Semantics::Control, Semantics::Switch]
          end

          expect(GroupPoint.points).to match_array([Brightness, MySwitch])
          expect(Brightness.points).to match_array([GroupPoint, MySwitch])
        end
      end
    end

    describe "#equipments" do
      it "gets sub-equipment" do
        items.build do
          group_item "SubEquipment", groups: [Patio_Light_Bulb], tags: [Semantics::Lightbulb]
        end
        expect(gPatio.equipments(Semantics::Lightbulb).members.equipments).to eql [SubEquipment]
      end
    end
  end

  describe "#equipments" do
    it "supports non-group equipments" do
      items.build do
        group_item "Group_Equipment", groups: [gIndoor], tags: [Semantics::Lightbulb] do
          dimmer_item "Brightness", tags: [Semantics::Control, Semantics::Level]
        end
        switch_item "NonGroup_Equipment", groups: [gIndoor], tags: [Semantics::Lightbulb]
      end
      expect(gIndoor.equipments).to match_array([Group_Equipment, NonGroup_Equipment])
    end
  end
end
