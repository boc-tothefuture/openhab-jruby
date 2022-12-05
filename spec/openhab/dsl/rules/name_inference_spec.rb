# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Rules::NameInference do
  shared_examples "item trigger" do
    it "generates a useful name" do
      trigger = self.trigger
      r = rules.build { send(trigger, SwitchItem1) { nil } }
      expect(r.name).to eql "SwitchItem1 #{trigger}"
    end

    it "generates a useful name for a to:" do
      trigger = self.trigger
      r = rules.build { send(trigger, SwitchItem1, to: ON) { nil } }
      expect(r.name).to eql "SwitchItem1 #{trigger} to ON"
    end

    it "generates a useful name for two to: states" do
      trigger = self.trigger
      r = rules.build { send(trigger, SwitchItem1, to: [NULL, UNDEF]) { nil } }
      expect(r.name).to eql "SwitchItem1 #{trigger} to NULL or UNDEF"
    end

    it "generates a useful name for three to: states" do
      trigger = self.trigger
      r = rules.build { send(trigger, SwitchItem1, to: [NULL, UNDEF, OFF]) { nil } }
      expect(r.name).to eql "SwitchItem1 #{trigger} to any of NULL, UNDEF, or OFF"
    end

    it "generates a useful name for a range to:" do
      trigger = self.trigger
      r = rules.build { send(trigger, NumberItem1, to: 1..10) { nil } }
      expect(r.name).to eql "NumberItem1 #{trigger} to 1..10"
    end
  end

  context "with #changed" do
    let(:trigger) { :changed }

    include_examples "item trigger"

    it "generates a useful name for a from:" do
      trigger = self.trigger
      r = rules.build { send(trigger, SwitchItem1, from: ON) { nil } }
      expect(r.name).to eql "SwitchItem1 changed from ON"
    end

    it "generates a useful name for a from: and to:" do
      trigger = self.trigger
      r = rules.build { send(trigger, SwitchItem1, from: OFF, to: ON) { nil } }
      expect(r.name).to eql "SwitchItem1 changed from OFF to ON"
    end
  end

  context "with #updated" do
    let(:trigger) { :updated }

    include_examples "item trigger"
  end

  context "with #received_command" do
    it "generates a useful name" do
      r = rules.build { received_command(SwitchItem1) { nil } }
      expect(r.name).to eql "SwitchItem1 received command"
    end

    it "generates a useful name with a command" do
      r = rules.build { received_command(SwitchItem1, command: ON) { nil } }
      expect(r.name).to eql "SwitchItem1 received command ON"
    end
  end

  context "with #on_start" do
    it "generates a useful name" do
      r = rules.build { on_start { nil } }
      expect(r.name).to eql "System Start Level reached 100 (:complete)"
    end
  end
end
