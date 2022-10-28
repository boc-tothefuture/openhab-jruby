# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Rules do
  describe "#remove_rule" do
    it "works" do
      my_rule = rule do
        every :day
        run { nil }
      end

      expect(described_class.script_rules.keys).to eql [my_rule.uid]
      remove_rule(my_rule)
      expect(described_class.script_rules).to be_empty
      expect($rules.get(my_rule.uid)).to be_nil
    end

    it "can re-add a rule with the same id after it has been removed" do
      rule id: "myid" do
        every :day
        run { nil }
      end

      remove_rule("myid")
      expect(described_class.script_rules).to be_empty
      expect($rules.get("myid")).to be_nil

      rule id: "myid" do
        every :day
        run { nil }
      end

      expect(described_class.script_rules.keys).to eql ["myid"]
      expect($rules.get("myid")).not_to be_nil
    end

    it "cleans up timers for a duration condition when the rule" do
      items.build { switch_item "Item1" }
      my_rule = rule do
        changed Item1, for: 5.minutes
        run { nil }
      end

      expect(OpenHAB::DSL::Timer::Manager.instance.active_timer_count).to be 0
      Item1.on
      expect(OpenHAB::DSL::Timer::Manager.instance.active_timer_count).to be 1
      remove_rule(my_rule)
      expect(OpenHAB::DSL::Timer::Manager.instance.active_timer_count).to be 0
    end
  end
end
