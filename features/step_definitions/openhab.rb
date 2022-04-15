# frozen_string_literal: true

require 'securerandom'
require 'json'

Given('Clean OpenHAB with latest Ruby Libraries') do
  delete_rules
  delete_shared_libraries
  delete_items
  delete_things
  delete_conf_foo
  truncate_log
end

Then(/^It should log "([^"]*)" within (\d+) seconds$/) do |string, seconds|
  wait_until(seconds: seconds.to_i,
             msg: "'#{string}' not found in log file (#{openhab_log}) within #{seconds} seconds") do
    check_log(string)
  end
end

Then(/^It should log '([^']*)' within (\d+) seconds$/) do |string, seconds|
  wait_until(seconds: seconds.to_i,
             msg: "'#{string}' not found in log file (#{openhab_log}) within #{seconds} seconds") do
    check_log(string)
  end
end

Then(%r{^It should log /(.*)/ within (\d+) seconds$}) do |regex, seconds|
  wait_until(seconds: seconds.to_i,
             msg: "/#{regex}/ not found in log file (#{openhab_log}) within #{seconds} seconds") do
    check_log_regexp(/#{regex}/)
  end
end

Then('It should log a line matching regex {string} within {int} seconds') do |regex, seconds|
  wait_until(seconds: seconds.to_i,
             msg: "'#{regex}' not found in log file (#{openhab_log}) within #{seconds} seconds") do
    check_log_regexp(regex)
  end
end

# rubocop:disable Layout/LineLength
Then('It should log only {string} at level {string} from {string} within {int} seconds') do |entry, level, logger, seconds|
  # 2021-11-15 19:24:34.574 [INFO ] [org.openhab.automation.jruby.rules.log_test] - Log Test
  # Trim level to the right most 36 chars (per logging config)
  logger_length = 36
  logger = logger[-logger_length, logger_length] if logger.length > logger_length
  regex = /^.*\[#{Regexp.quote(level.upcase)}\s*\]\s+\[#{Regexp.quote(logger)}\s*\]\s-\s#{Regexp.quote(entry)}\s*$/
  wait_until(seconds: seconds.to_i,
             msg: "'#{entry}' at level '#{level}' from logger '#{logger}' not found in log file (#{openhab_log}) within #{seconds} seconds") do
    check_log_regexp(regex)
  end
end
# rubocop:enable Layout/LineLength

Then('It should not log {string} within {int} seconds') do |string, seconds|
  not_for(seconds: seconds, msg: "'#{string}'' found in log file (#{openhab_log}) within #{seconds} seconds") do
    check_log(string)
  end
end

Given('OpenHAB is stopped') do
  stop_openhab
end

When('I start OpenHAB') do
  start_openhab
end

Given('GEM_HOME is empty') do
  clear_gem_path
end

Given('a services template filed named {string}') do |file, doc_string|
  File.write(File.join(services_dir, file), ERB.new(doc_string).result)
end

Given('group {string}') do |group|
  add_group(name: group)
end

Given('groups:') do |table|
  table.hashes.each do |row|
    item = item_from_row(row, type: 'Group', group_type: row['type'])
    add_item(item: item)
  end
end

def nil_if_blank(str)
  str = nil if str&.strip == ''
  str
end

def check_items(added:)
  wait_until(seconds: 10, msg: "Not all #{added} items were added") do
    (added.map(&:name) - (Rest.items.map { |item| item['name'] })).empty?
  rescue StandardError
    false
  end
end

Given(/(?: I add)?items:/) do |table|
  items = []
  table.hashes.each do |row|
    item = item_from_row(row, type: row['type'])
    add_item(item: item)
    items << item
  end
  check_items(added: items)
end

Given('linked:') do |table|
  table.hashes.each do |row|
    link_item(item_name: row['item'], channel_uid: row['channel'])
  end
end

Given('things:') do |table|
  table.hashes.each do |row|
    id = row['id']
    thing_type_uid = row['thing_uid']
    label = row['label']
    uid = [thing_type_uid, id].join(':')
    config = nil_if_blank(row['config'])
    config = JSON.parse(config) if config
    Rest.add_thing(id: id, uid: uid, thing_type_uid: thing_type_uid, label: label, config: config)
    status = nil_if_blank(row['status'])
    openhab_client("openhab:things #{status} #{uid}") if status
  end
end

When('thing {string} is disabled') do |thing|
  openhab_client("openhab:things disable #{thing}")
end

When('thing {string} is enabled') do |thing|
  openhab_client("openhab:things enable #{thing}")
end

Given('item states:') do |table|
  table.hashes.each do |row|
    item = row['item']
    state = row['state']
    Rest.set_item_state(item, state)
  end
end

Then('The rule {string} should have {string} as its description') do |rule, description|
  rule_details = Rest.rule(rule: rule)
  unless rule_details['description']&.chomp == description.chomp
    raise "Rule #{rule} has description '#{rule_details['description']}' instead of '#{description}'"
  end
end

Given('item updates:') do |table|
  table.hashes.each do |row|
    item = row['item']
    state = row['state']
    openhab_client("openhab:update #{item} #{state}")
  end
end

When('item {string} state is changed to {string}') do |item, state|
  openhab_client("openhab:send #{item} #{state}")
end

Then('If I send command {string} to item {string}') do |state, item|
  openhab_client("openhab:send #{item} #{state}")
end

When('update state for item {string} to {string}') do |item, state|
  openhab_client("openhab:update #{item} \"#{state}\"")
end

When('channel {string} is triggered') do |channel|
  openhab_client("openhab:things trigger #{channel}")
end

Given('feature {string} installed') do |feature|
  install_feature(feature)
end

When('channel {string} is triggered with {string}') do |channel, event|
  openhab_client("openhab:things trigger #{channel} #{event}")
end

Then('{string} should be in state {string} within {int} seconds') do |item, state, seconds|
  msg = -> { "'#{item}' did not get set to (#{state}) was (#{Rest.item_state(item)}) within #{seconds} seconds" }

  wait_until(seconds: seconds, msg: msg) do
    Rest.item_state(item) == state
  end
end

Then('{string} should stay in state {string} for {int} seconds') do |item, state, seconds|
  elapsed = 0
  seconds.times do
    unless Rest.item_state(item) == state
      raise "'#{item}' did not stay in state (#{state}) for #{seconds} seconds, "\
            "changed to (#{Rest.item_state(item)}) within #{elapsed} seconds"
    end

    sleep 1
    elapsed += 1
  end
end

Given('metadata added to {string} in namespace {string}:') do |item, namespace, config|
  response = Rest.add_metadata(item: item, namespace: namespace, config: config)
  raise "Response #{response.pretty_inspect} Request #{response.request.pretty_inspect}" unless response.success?
end

Given('(set )log level (to ){word}') do |level|
  set_log_level('org.openhab.automation.jruby', level)
  set_log_level('org.openhab.automation.jrubyscripting', level)
  set_log_level('org.openhab.core.automation', level)
end

Given('log level for {word} is set to {word}') do |bundle, level|
  set_log_level(bundle, level)
end

#
# Create an Item object from row
#
# @param [Hash] row input hash
#
# @return [Item]
#
def item_from_row(row, type:, group_type: nil) # rubocop:disable Metrics/AbcSize
  name = row['name']
  label = nil_if_blank(row['label'])
  pattern = nil_if_blank(row['pattern'])
  function = nil_if_blank(row['function'])
  state = nil_if_blank(row['state'])

  params = array_from_list(row['params'])
  groups = array_from_list(row['group'], row['groups'])
  tags = array_from_list(row['tag'], row['tags'])

  Item.new(type: type, name: name, label: label, tags: tags, groups: groups, group_type: group_type,
           pattern: pattern, function: function, params: params, state: state)
end

def array_from_list(*list)
  list.compact.flat_map { |data| data.split(',').map(&:strip) }
end
