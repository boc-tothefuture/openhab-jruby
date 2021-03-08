# frozen_string_literal: true

# General non-openhab specific steps

require 'fileutils'
require 'tmpdir'

Then('If I wait {int} seconds') do |int|
  sleep(int)
end

When('(if )I wait {int} seconds') do |int|
  sleep(int)
end

Given('file {string} is in the system temp dir') do |filename|
  FileUtils.cp(File.join(__dir__, '../assets', filename), File.join(Dir.tmpdir))
end
