# frozen_string_literal: true

RSpec.describe "OpenHAB::DSL::Rules::Triggers on thing status" do # rubocop:disable RSpec/EmptyExampleGroup examples are dynamically generated
  before do
    install_addon "binding-astro", ready_markers: "openhab.xmlThingTypes"
  end

  let!(:thing) do
    things.build { thing "astro:sun:home", config: { "geolocation" => "0,0" }, enabled: true }
  end

  def self.test_status_trigger(trigger, from: nil, to: nil, duration: nil, expect_triggered: true, &block)
    description = "supports status #{trigger} trigger"
    description += " from: #{from.inspect}" if from
    description += " to: #{to.inspect}" if to
    description += " for: #{duration.inspect}" if duration

    it description, caller: caller do
      # this is the only way to make this accessible to both
      # the rule where it's set, and to the block given to the
      # definition method
      @triggered = false

      class << self
        attr_writer :triggered

        def triggered?
          @triggered # rubocop:disable RSpec/InstanceVariable
        end
      end

      rule "Execute rule when thing is #{trigger}" do
        kwargs = { to: to }
        kwargs[:from] = from if from
        kwargs[:for] = duration if duration

        send(trigger, things["astro:sun:home"], **kwargs)
        run { self.triggered = true }
      end
      expect(thing.status.to_s).to eq "ONLINE"
      thing.disable
      expect(thing.status.to_s).to eq "UNINITIALIZED"
      if block
        instance_eval(&block)
      else
        expect(triggered?).to be expect_triggered
      end
    end
  end

  test_status_trigger(:changed)
  test_status_trigger(:updated)
  test_status_trigger(:changed, to: :uninitialized)
  test_status_trigger(:updated, to: :uninitialized)
  test_status_trigger(:changed, to: :unknown, expect_triggered: false)
  test_status_trigger(:updated, to: :unknown, expect_triggered: false)
  test_status_trigger(:changed, from: :online)
  test_status_trigger(:changed, from: :unknown, expect_triggered: false)
  test_status_trigger(:changed, from: :online, to: :uninitialized)
  test_status_trigger(:changed, from: :unknown, to: :uninitialized, expect_triggered: false)
  test_status_trigger(:changed, to: :uninitialized, duration: 10.seconds) do |_triggered|
    execute_timers
    expect(triggered?).to be false
    Timecop.travel(15.seconds)
    execute_timers
    expect(triggered?).to be true
  end
  test_status_trigger(:changed, to: :uninitialized, duration: 20.seconds) do |_triggered|
    execute_timers
    expect(triggered?).to be false
    Timecop.travel(5.seconds)
    thing.enable
    execute_timers
    expect(triggered?).to be false
    Timecop.travel(20.seconds)
    execute_timers
    expect(triggered?).to be false
  end
end
