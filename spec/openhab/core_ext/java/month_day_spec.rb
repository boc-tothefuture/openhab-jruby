# frozen_string_literal: true

RSpec.describe java.time.MonthDay do
  describe "comparisons" do
    let(:feb3) { MonthDay.of(2, 3) }

    specify { expect(feb3).to eq "02-03" }
    specify { expect(feb3).to eq "02-3" }
    specify { expect(feb3).to eq "2-03" }
    specify { expect(feb3).to eq "2-3" }
    specify { expect(feb3).to eq "--2-3" }
  end
end
