# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Items::LocationItem do
  subject(:item) { Location1 }

  before do
    items.build do
      location_item "Location1", state: "30,20"
      location_item "Location2", state: "40,20"
    end
  end

  describe "can be updated" do
    specify { expect((item << "30,20").state).to eq PointType.new("30,20") }
    specify { expect((item << "30,20,80").state).to eq PointType.new("30,20,80") }
    specify { expect((item << PointType.new("40,20")).state).to eq PointType.new("40,20") }
  end
end
