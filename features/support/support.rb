# frozen_string_literal: true

def wait_until(seconds:, msg:)
  seconds.times do
    return if yield

    sleep 1
  end
  msg = msg.call if msg.is_a? Proc
  raise msg
end

def not_for(seconds:, msg:)
  seconds.times do
    raise msg if yield

    sleep 1
  end
end
