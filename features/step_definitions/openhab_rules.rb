# frozen_string_literal: false

require 'tempfile'
require 'fileutils'
require 'securerandom'

def require_openhab
  "require 'openhab'"
end

def doc_string_to_rule(doc_string)
  "#{require_openhab}\n\n#{doc_string}\n"
end

def identifying_started_log_line(uid)
  "Processing Started for #{uid}"
end

def identifying_log_line(uid)
  "Processing Complete for #{uid}"
end

def prepend_identifying_log_line_to_rule(uid)
  @rule.insert require_openhab.length, %[\n\nlogger.info("#{identifying_started_log_line(uid)}")\n\n]
end

def append_identifying_log_line_to_rule(uid)
  @rule += %[\n\nlogger.info("#{identifying_log_line(uid)}")\n\n]
end

def atomic_rule_write(rule_content, deploy_path)
  temp_file = Tempfile.create(['cucumber_test', '.rb'])
  temp_file.write(rule_content)
  temp_file.close

  FileUtils.move temp_file, deploy_path
end

def create_log_markers(uid)
  prepend_identifying_log_line_to_rule(uid)
  append_identifying_log_line_to_rule(uid)
end

def deploy_rule(filename: '', check_position: :end, check: true)
  uid = SecureRandom.uuid

  log_line = case check_position
             when :start then identifying_started_log_line(uid)
             when :end then identifying_log_line(uid)
             else raise ArgumentError, 'log_line can either be :start or :end'
             end

  create_log_markers(uid)
  atomic_rule_write(@rule, File.join(rules_dir, filename))
  wait_until(seconds: 60, msg: 'Rule not added') { check_log(log_line) } if check
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

When('I start deploying the rule') do
  deploy_rule(:check_position => :start)
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
