# frozen_string_literal: true

RSpec.describe "mocks" do
  it "mocks against the actual item" do
    items.build { switch_item Switch1 }

    expect(Switch1).to receive(:command).with(ON).twice

    Switch1.on
    Switch1 << ON
  end

  context "without consistent proxies" do
    self.consistent_proxies = false

    it "only mocks the proxy" do
      items.build { switch_item Switch1 }

      expect(Switch1.__getobj__).to receive(:command).with(ON).twice
      expect(Switch1).not_to receive(:command)

      Switch1.on
      Switch1 << ON
    end
  end
end
