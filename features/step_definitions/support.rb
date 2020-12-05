# frozen_string_literal: true

# General non-openhab specific steps

Then('If I wait {int} seconds') do |int|
  sleep(int)
end
