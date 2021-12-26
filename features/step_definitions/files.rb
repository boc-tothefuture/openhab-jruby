# frozen_string_literal: true

require 'securerandom'

def create_sub_file(dir, file)
  conf_sub_dir = File.join(conf_dir, dir)
  Dir.mkdir conf_sub_dir unless File.exist? conf_sub_dir
  temp_conf_file(conf_sub_dir)
  conf_file = File.join(conf_sub_dir, file)
  File.open(conf_file, 'w') { |f| f.write(SecureRandom.hex) }
  temp_conf_file(conf_file)
end

Given('a file in subdirectory {string} of conf named {string}') do |dir, file|
  create_sub_file(dir, file)
end

When('I create a file in subdirectory {string} of conf named {string}') do |dir, file|
  create_sub_file(dir, file)
end

When('I delete a file in subdirectory {string} of conf named {string}') do |dir, file|
  File.delete File.join(conf_dir, dir, file)
end

When('I modify a file in subdirectory {string} of conf named {string}') do |dir, file|
  File.open(File.join(conf_dir, dir, file), 'w') { |f| f.write(SecureRandom.hex) }
end

Given('a subdirectory {string} of conf') do |sub_dir|
  Dir.mkdir File.join(conf_dir, sub_dir)
end
