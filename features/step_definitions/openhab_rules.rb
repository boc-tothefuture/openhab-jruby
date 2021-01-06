# frozen_string_literal: true

require 'securerandom'

def doc_string_to_rule(doc_string)
  "require 'openhab'\n\n#{doc_string}\n"
end

def identifying_log_line(uid)
  "Processing Complete for #{uid}"
end

def append_identifying_log_line_to_rule(uid)
  @rule += %[\n\nlogger.info("#{identifying_log_line(uid)}")\n\n]
end

def deploy_rule(filename: nil, check: true)
  FileUtils.mkdir_p rules_dir
  uid = SecureRandom.uuid

  filename ||= "cucumber_test_#{uid}.rb"

  deploy_path = File.join(rules_dir, filename)
  append_identifying_log_line_to_rule(uid)
  File.write(File.join(deploy_path), @rule)
  wait_until(seconds: 30, msg: 'Rule not added') { check_log(identifying_log_line(uid)) } if check
end

Given('a rule(:)') do |doc_string|
  @rule = doc_string_to_rule(doc_string)
end

Given('a rule template(:)') do |doc_string|
  @rule = doc_string_to_rule(ERB.new(doc_string).result)
end

Given('a deployed rule(:)') do |doc_string|
  @rule = doc_string_to_rule(doc_string)
  deploy_rule
end

When('I deploy the rule(:)') do
  deploy_rule
end

When('I deploy a rule with an error') do
  deploy_rule(check: false)
end

Given('code in a rules file(:)') do |doc_string|
  @rule = doc_string_to_rule(doc_string)
end

Given('code in a deployed rules file(:)') do |doc_string|
  @rule = doc_string_to_rule(doc_string)
  deploy_rule
end

When('I deploy the rules file') do
  deploy_rule
end

When('I deploy the rules file named {string}') do |file|
  deploy_rule(filename: file)
end
