# frozen_string_literal: true

def wait_until(seconds:, msg:, sleep_duration: 1)
  seconds.times do
    return if yield

    sleep sleep_duration
  end
  msg = msg.call if msg.is_a?(Proc)
  raise msg
end

def not_for(seconds:, msg:, sleep_duration: 1)
  seconds.times do
    raise msg if yield

    sleep sleep_duration
  end
end
