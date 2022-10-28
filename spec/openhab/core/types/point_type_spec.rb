# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Types::PointType do
  let(:point1) { PointType.new("30,20") }
  let(:point2) { PointType.new("40,20") }

  it "aliases `-` to `distance_from`" do
    expect((point1 - point2).to_i).to be 1_113_194
  end

  describe "#distance_from accepts supported types" do
    specify { expect(point1.distance_from(point2).to_i).to be 1_113_194 }
    specify { expect(point1.distance_from("40,20").to_i).to be 1_113_194 }
    specify { expect(point1.distance_from({ lat: 40, long: 20 }).to_i).to be 1_113_194 }
    specify { expect(point1.distance_from({ latitude: 40, longitude: 20 }).to_i).to be 1_113_194 }
    specify { expect(point2.distance_from(point1).to_i).to be 1_113_194 }
  end
end
