# frozen_string_literal: true

require 'securerandom'
require 'json'
require 'pp'

Given('Clean OpenHAB with latest Ruby Libraries') do
  system('rake openhab:deploy 1>/dev/null 2>/dev/null') || raise('Error Deploying Libraries')
  ensure_openhab_running
  delete_rules
  delete_items
  delete_things
  truncate_log
end

Then(/^It should log "([^"]*)" within (\d+) seconds$/) do |string, seconds|
  wait_until(seconds: seconds.to_i, msg: "'#{string}' not found in log file (#{openhab_log}) within #{seconds} seconds") do
    check_log(string)
  end
end

Then(/^It should log '([^']*)' within (\d+) seconds$/) do |string, seconds|
  wait_until(seconds: seconds.to_i, msg: "'#{string}' not found in log file (#{openhab_log}) within #{seconds} seconds") do
    check_log(string)
  end
end

Given('metadata added to {string} in namespace {string}:') do |item, namespace, config|
  response = Rest.add_metadata(item: item, namespace: namespace, config: config)
  raise "Response #{response.pretty_inspect} Request #{response.request.pretty_inspect}" unless response.success?

end

Then('It should not log {string} within {int} seconds') do |string, seconds|
  not_for(seconds: seconds, msg: "'#{string}'' found in log file (#{openhab_log}) within #{seconds} seconds") do
    check_log(string)
  end
end

Given('group {string}') do |group|
  add_group(name: group)
end

Given('groups:') do |table|
  table.hashes.each do |row|
    group_type = row['type']
    name = row['name']
    function = row['function']
    params = row['params']&.split(',')
    groups = [row['group']]
    add_group(name: name, group_type: group_type, groups: groups, function: function, params: params)
  end
end

def nil_if_blank(str)
  str = nil if str&.strip == ''
  str
end

Given(/(?: I add)?items:/) do |table|
  table.hashes.each do |row|
    type = row['type']
    name = row['name']
    label = nil_if_blank(row['label'])
    groups = [row['group']]
    groups << row['groups']&.split(',')
    groups = groups&.flatten
    state = nil_if_blank(row['state'])
    pattern = nil_if_blank(row['pattern'])
    add_item(type: type, name: name, state: state, label: label, groups: groups, pattern: pattern)
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

When('update state for item {string} to {string}') do |item, state|
  openhab_client("openhab:update #{item} #{state}")
end

When('channel {string} is triggered') do |channel|
  openhab_client("openhab:things trigger #{channel}")
end

Given('feature {string} installed') do |feature|
  openhab_client("feature:install #{feature}")
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
