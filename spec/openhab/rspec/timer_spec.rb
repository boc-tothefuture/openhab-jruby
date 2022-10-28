# frozen_string_literal: true

RSpec.describe "timers" do
  it "only executes after time has moved, and you explicitly execute them" do
    executed = false
    after(5.minutes) { executed = true }

    expect(executed).to be false
    Timecop.travel(10.minutes)
    expect(executed).to be false
    execute_timers
    expect(executed).to be true
  end
end
