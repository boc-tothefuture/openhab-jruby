# frozen_string_literal: true

require 'securerandom'

Given('Clean OpenHAB with latest Ruby Libraries') do
  system('rake openhab:deploy 1>/dev/null 2>/dev/null') || raise('Error Deploying Libraries')
  ensure_openhab_running
  delete_rules
  delete_items
  truncate_log
end

Then('It should log {string} within {int} seconds') do |string, seconds|
  wait_until(seconds: seconds, msg: "'#{string}' not found in log file (#{openhab_log}) within #{seconds} seconds") do
    check_log(string)
  end
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

Given(/(?: I add)?items:/) do |table|
  table.hashes.each do |row|
    type = row['type']
    name = row['name']
    label = row['label']
    groups = [row['group']]
    groups << row['groups']&.split(',')
    groups = groups&.flatten
    state = row['state']
    add_item(type: type, name: name, state: state, label: label, groups: groups)
  end
end

When('item {string} state is changed to {string}') do |item, state|
  openhab_client("openhab:send #{item} #{state}")
end

When('update state for item {string} to {string}') do |item, state|
  openhab_client("openhab:update #{item} #{state}")
end

Then('{string} should be in state {string} within {int} seconds') do |item, state, seconds|
  wait_until(seconds: seconds, msg: "'#{item}' did not get set to (#{state}) within #{seconds} seconds") do
    Rest.item_state(item) == state
  end
end
