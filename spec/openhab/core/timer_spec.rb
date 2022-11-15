# frozen_string_literal: true

RSpec.describe OpenHAB::Core::Timer do
  before { Timecop.freeze }

  # #to_i is used when checking execution time because OpenHAB's timer not only
  # loses sub-millisecond precision, but replaces it with (real) now's value.
  shared_examples_for "Timer interface" do
    it "works" do
      fired = false
      t = after(0.1.seconds) do |timer|
        fired = true
        expect(timer).to be t # rubocop:disable RSpec/ExpectInHook
      end
      expect(t).not_to be_a(OpenHAB::RSpec::Mocks::Timer) unless self.class.mock_timers?
      expect(fired).to be false
      time_travel_and_execute_timers(0.5.second)
      expect(fired).to be true
    end

    describe "#reschedule" do
      it "works" do
        start = Time.now
        next_time = start + 15.seconds
        final_time = start + 30.seconds
        t = after(15.seconds) { nil }
        expect(t.execution_time.to_i).to eq next_time.to_i
        Timecop.travel(next_time)
        t.reschedule
        expect(t.execution_time.to_i).to eq final_time.to_i
      end

      it "accepts a new offset (but doesn't memoize it)" do
        start = Time.now
        next_time = start + 15.seconds
        second_time = start + 45.seconds
        final_time = start + 60.seconds
        t = after(15.seconds) { nil }
        expect(t.execution_time.to_i).to eq next_time.to_i
        Timecop.travel(next_time)
        t.reschedule(30.seconds)
        expect(t.execution_time.to_i).to eq second_time.to_i
        Timecop.travel(second_time)
        t.reschedule
        expect(t.execution_time.to_i).to eq final_time.to_i
      end
    end

    it "supports integral durations" do
      t = after(5.minutes) { nil }
      expect(t.execution_time.to_i).to eql 5.minutes.from_now.to_i
    end

    it "supports non-integral durations" do
      t = after(0.5.minutes) { nil }
      expect(t.execution_time.to_i).to eql 30.seconds.from_now.to_i
    end

    it "supports absolute ZonedDateTime" do
      time = ZonedDateTime.parse("2030-01-01T00:00:00+00:00")
      t = after(time) { nil }
      expect(t.execution_time.to_i).to eql time.to_i
    end

    it "supports Time" do
      time = Time.parse("2030-01-01T00:00:00+00:00")
      t = after(time) { nil }
      expect(t.execution_time.to_i).to eq time.to_i
    end

    it "supports Procs" do
      start = Time.now
      next_time = start + 15.seconds
      final_time = start + 30.seconds
      t = after(-> { 15.seconds }) { nil }
      expect(t.execution_time.to_i).to eq next_time.to_i
      Timecop.travel(next_time)
      t.reschedule
      expect(t.execution_time.to_i).to eq final_time.to_i
    end

    describe "#active?" do
      it "is true for a pending timer" do
        t = after(5.minutes) { nil }
        expect(t).to be_active
      end

      it "is false if the timer has been canceled" do
        t = after(5.minutes) { nil }
        t.cancel
        expect(t).not_to be_active
      end

      it "is false if the timer has been executed" do
        t = after(0.1.seconds) { nil }
        time_travel_and_execute_timers(0.5.seconds)
        expect(t).not_to be_active
      end
    end

    describe "#terminated?" do
      it "is false for a pending timer" do
        t = after(5.minutes) { nil }
        expect(t).not_to be_terminated
      end

      it "is true if the timer has been canceled" do
        t = after(5.minutes) { nil }
        t.cancel
        expect(t).to be_terminated
      end

      it "is true if the timer has been executed" do
        t = after(0.1.seconds) { nil }
        time_travel_and_execute_timers(0.5.seconds)
        expect(t).to be_terminated
      end
    end

    it "responds to #running?" do
      t = after(5.minutes) { nil }
      expect(t.respond_to?(:running?)).to be true
    end

    context "with id" do
      def start_timer(duration)
        after(duration, id: "id") { nil }
      end

      it "reuses the same timer if an id is given" do
        timer1 = start_timer(5.seconds)
        expect(timer1.execution_time.to_i).to be 5.seconds.from_now.to_i
        start_timer(5.seconds)
        expect(timer1).to be_cancelled
      end

      it "changes its duration to the latest call" do
        start_timer(10.seconds)
        timer = start_timer(5.seconds)
        timer.reschedule
        expect(timer.execution_time.to_i).to be 5.seconds.from_now.to_i
      end

      it "can find a timer by id" do
        timer = start_timer(5.seconds)
        expect(timers["id"].to_a).to eql [timer]
      end

      it "removes the timer when canceled" do
        start_timer(5.seconds)
        timers["id"].cancel
        expect(timers).not_to have_key("id")
      end

      it "can reschedule a set of timers" do
        start_timer(5.seconds)
        timers["id"].reschedule(1.second)
        expect(timers["id"].first.execution_time.to_i).to be 1.second.from_now.to_i
      end
    end
  end

  context "with real timers" do
    # We need to actually test them here
    self.mock_timers = false
    include_examples "Timer interface"

    it "doesn't mock timers" do
      expect(self.class.mock_timers?).to be false
    end
  end

  context "with mock timers" do
    include_examples "Timer interface"

    it "mocks timers" do
      expect(self.class.mock_timers?).to be true
    end
  end
end
