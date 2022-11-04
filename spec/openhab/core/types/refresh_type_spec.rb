# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Types::RefreshType do
  it "is inspectable" do
    expect(REFRESH.inspect).to eql "REFRESH"
  end

  describe "comparisons" do
    specify { expect(REFRESH).not_to eq NULL }
    specify { expect(REFRESH).not_to eq UNDEF }
    specify { expect(REFRESH).not_to eq ON }
    specify { expect(REFRESH).not_to eq OFF }
    specify { expect(REFRESH).not_to eq UP }
    specify { expect(REFRESH).to eq REFRESH }

    specify { expect(REFRESH != NULL).to be true }
    specify { expect(REFRESH != UNDEF).to be true }
    specify { expect(REFRESH != ON).to be true }
    specify { expect(REFRESH != OFF).to be true }
    specify { expect(REFRESH != UP).to be true }
    specify { expect(REFRESH != REFRESH).to be false }
  end
end
