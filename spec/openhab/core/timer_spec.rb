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
        timer1 = after(5.seconds, id: "id") { nil }
        expect(timer1.execution_time.to_i).to be 5.seconds.from_now.to_i
        after(5.seconds, id: "id") { nil }

        expect(timer1).to be_cancelled
      end

      it "changes its duration to the latest call" do
        start_timer(10.seconds)
        timer = start_timer(5.seconds)
        timer.reschedule
        expect(timer.execution_time.to_i).to be 5.seconds.from_now.to_i
      end

      it "can find a timer by id" do
        after(5.seconds, id: "id") { nil }

        expect(timers).to include("id")
      end

      it "removes the timer when canceled" do
        after(5.seconds, id: "id") { nil }

        timers.cancel("id")
        expect(timers).not_to include("id")
      end

      it "can reschedule a timer by id" do
        timer1 = after(5.seconds, id: "id") { nil }
        timer2 = timers.reschedule("id", 1.second)
        expect(timer2).to be timer1
        expect(timer1.execution_time.to_i).to be 1.second.from_now.to_i
      end

      it "can avoid rescheduling timers that already exist" do
        first_executed = second_executed = false
        timer1 = after(5.seconds, id: "id") { first_executed = true }
        timer2 = after(10.seconds, id: "id", reschedule: false) { second_executed = false }
        expect(timer2).to be timer1

        next unless self.class.mock_timers?

        time_travel_and_execute_timers(20.seconds)
        expect(first_executed).to be true
        expect(second_executed).to be false
      end

      describe "TimerManager#schedule" do
        it "requires the block to return a valid timer" do
          proper_timer_class = self.class.mock_timers? ? OpenHAB::RSpec::Mocks::Timer : described_class
          real_timer = after(1.second) { nil }
          fake_timer = Struct.new(:id).new(nil)

          expect(timers.schedule("id") { real_timer }).to be_a(proper_timer_class)
          expect { timers.schedule("id") { fake_timer } }.to raise_exception(ArgumentError, /must return a timer/i)
        end
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

    describe "TimerManager#schedule" do
      it "can _not_ schedule anything if you want" do
        timers.schedule("id") do |timer|
          expect(timer).to be_nil
          nil
        end
      end

      it "can schedule a timer" do
        timer1 = nil
        executed = false
        timer2 = timers.schedule("id") do |_|
          timer1 = after(5.seconds) { executed = true }
        end
        expect(timer2).not_to be_nil
        expect(timer2).to be timer1
        expect(timer1.id).to eql "id"
        expect(executed).to be false
        expect(timers).to include("id")

        timer3 = timers.schedule("id") do |timer|
          expect(timer).to be timer1
          timer
        end
        expect(timer3).to be timer1

        time_travel_and_execute_timers(10.seconds)
        expect(executed).to be true
      end

      it "can reschedule an existing timer" do
        executed = false
        timers.schedule("id") do |_|
          after(5.seconds) { executed = true }
        end

        timers.schedule("id") do |timer|
          timer.reschedule(10.seconds)
        end

        time_travel_and_execute_timers(7.seconds)
        expect(executed).to be false
        time_travel_and_execute_timers(7.seconds)
        expect(executed).to be true
      end

      it "cancels a timer if you return nil from the block" do
        executed = false
        timers.schedule("id") do |_|
          after(5.seconds) { executed = true }
        end

        timers.schedule("id") do |_|
          nil
        end

        expect(timers).not_to include("id")
        time_travel_and_execute_timers(7.seconds)
        expect(executed).to be false
      end

      it "removes a canceled timer" do
        executed = false
        timers.schedule("id") do |_|
          after(5.seconds) { executed = true }
        end

        timers.schedule("id") do |timer|
          timer.tap(&:cancel)
        end

        expect(timers).not_to include("id")
        time_travel_and_execute_timers(7.seconds)
        expect(executed).to be false
      end
    end
  end
end
