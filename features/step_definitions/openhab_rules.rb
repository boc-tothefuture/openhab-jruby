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

def prepend_identifying_log_line_to_rule(code, uid)
  pattern = require_openhab.gsub %(['"]), %(['"]) # allow raw rules with `require "openhab"` and `require 'openhab'`
  code.sub!(/#{pattern}/, %[#{require_openhab}\n\nlogger.info("#{identifying_started_log_line(uid)}")\n\n])
end

def append_identifying_log_line_to_rule(code, uid)
  code << %[\n\nlogger.info("#{identifying_log_line(uid)}")\n\n]
end

def atomic_rule_write(rule_content, deploy_path)
  temp_file = Tempfile.create(['cucumber_test', '.rb'])
  temp_file.write(rule_content)
  temp_file.close

  FileUtils.move temp_file, deploy_path
end

def create_log_markers(code, uid)
  prepend_identifying_log_line_to_rule(code, uid)
  append_identifying_log_line_to_rule(code, uid)
end

def deploy_shared_file(**kwargs)
  # check is always false, because shared code is never run immmediately
  deploy_ruby_file(directory: ruby_lib_dir, check: false, **kwargs)
end

def deploy_rule(**kwargs)
  deploy_ruby_file(directory: rules_dir, code: @rule, **kwargs)
  sleep 1
end

def wait_for_rule(log_line)
  if ENV['RELOAD_SCRIPTS_BUNDLE']
    # force the bundle for ScriptFileWatcher to re-scan immediately; otherwise
    # it can take up to 20s to notice the new rule file when Java's
    # WatchService doesn't support actively watching, and only polls (i.e. on
    # MacOS)
    openhab_client('bundle:restart org.openhab.core.automation.module.script.rulesupport')
  end
  wait_until(seconds: 60, msg: 'Rule not added') { check_log(log_line) }
end

def deploy_ruby_file(code:, directory:, filename: '', check_position: :end, check: true)
  uid = SecureRandom.uuid

  log_line = case check_position
             when :start then identifying_started_log_line(uid)
             when :end then identifying_log_line(uid)
             else raise ArgumentError, 'log_line can either be :start or :end'
             end

  create_log_markers(code, uid) if check
  atomic_rule_write(code, File.join(directory, filename))
  wait_for_rule(log_line) if check
end

# A raw rule is one where we don't automatically insert `require 'openhab'`
# It must be inserted manually in the code doc_string by the test author.
# This gives the author control over what goes before the require line.
Given('a raw rule(:)') do |doc_string|
  @rule = doc_string
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

Given('code in a shared file named {string}(:)') do |file, doc_string|
  code = doc_string_to_rule(doc_string)
  deploy_shared_file(filename: file, code: code)
end

When('I deploy the rules file') do
  deploy_rule
end

When('I deploy the rules file named {string}') do |file|
  deploy_rule(filename: file)
end

When('I remove the rules file') do
  delete_rules
end
