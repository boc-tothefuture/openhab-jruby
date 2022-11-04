# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Types::UnDefType do
  describe "comparisons" do
    specify { expect(NULL).to eq NULL }
    specify { expect(NULL).not_to eq UNDEF }
    specify { expect(NULL).not_to eq ON }
    specify { expect(NULL).not_to eq OFF }
    specify { expect(NULL).not_to eq UP }
    specify { expect(NULL).not_to eq REFRESH }

    specify { expect(UNDEF).not_to eq NULL }
    specify { expect(UNDEF).to eq UNDEF }
    specify { expect(UNDEF).not_to eq ON }
    specify { expect(UNDEF).not_to eq OFF }
    specify { expect(UNDEF).not_to eq UP }
    specify { expect(UNDEF).not_to eq REFRESH }

    specify { expect(NULL != NULL).to be false }
    specify { expect(NULL != UNDEF).to be true }
    specify { expect(NULL != ON).to be true }
    specify { expect(NULL != OFF).to be true }
    specify { expect(NULL != UP).to be true }
    specify { expect(NULL != REFRESH).to be true }

    specify { expect(UNDEF != NULL).to be true }
    specify { expect(UNDEF != UNDEF).to be false }
    specify { expect(UNDEF != ON).to be true }
    specify { expect(UNDEF != OFF).to be true }
    specify { expect(UNDEF != UP).to be true }
    specify { expect(UNDEF != REFRESH).to be true }
  end
end
