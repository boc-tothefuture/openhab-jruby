# frozen_string_literal: true

RSpec.describe OpenHAB::RSpec::Helpers do
  subject(:helpers) { Object.new.tap { |o| o.extend described_class } }

  describe "load_rules" do
    it "respects start levels" do
      allow(Dir).to receive(:[]).and_return(%w[automation/filea.rb automation/sl30/filec.rb
                                               automation/filea.sl20.rb automation/sl30/fileb.rb])
      # rubocop:disable RSpec/SubjectStub
      expect(helpers).to receive(:load).with("automation/filea.sl20.rb").ordered
      expect(helpers).to receive(:load).with("automation/sl30/fileb.rb").ordered
      expect(helpers).to receive(:load).with("automation/sl30/filec.rb").ordered
      expect(helpers).to receive(:load).with("automation/filea.rb").ordered
      # rubocop:enable RSpec/SubjectStub
      load_rules
    end
  end
end
