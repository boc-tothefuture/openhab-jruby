# frozen_string_literal: true

require_relative 'openhab_rest'
require 'English'

def openhab_dir
  File.realpath 'tmp/openhab'
end

def openhab_client(command)
  karaf_client_path = File.join(openhab_dir, 'runtime/bin/client')
   #Kernel.puts `#{karaf_client_path} -p habopen "#{command}"`
  `#{karaf_client_path} -p habopen "#{command}"`
  abort("OpenHAB command (#{command}) failed.") unless $CHILD_STATUS == 0
end

def items_dir
  File.join(openhab_dir, 'conf/items/')
end

def rules_dir
  File.join(openhab_dir, 'conf/automation/jsr223/ruby/personal/')
end

def openhab_log
  File.join(openhab_dir, 'userdata/logs/openhab.log')
end

def ensure_openhab_running
  `#{File.join(openhab_dir, 'runtime/bin/status')}`
  abort('Openhab not running') unless $CHILD_STATUS == 0
end

def check_log(entry)
  File.foreach(openhab_log).grep(/#{Regexp.escape(entry)}/).any?
end

def add_group(name:, group_type: nil, groups: nil, function: nil, params: nil)
  Rest.add_item(type: 'Group', name: name, groups: groups, group_type: group_type, function: function, params: params)
end

def add_item(type:, name:, state: nil, label: nil, groups: nil, pattern: nil)
  Rest.add_item(type: type, name: name, state: state, label: label, groups: groups, pattern: pattern)
end

def truncate_log
  File.open(openhab_log, File::TRUNC) {}
end

def delete_rules
  FileUtils.rm Dir.glob(File.join(rules_dir, '*.rb'))
  Rest.rules.each do |rule|
    uid = rule['uid']
    Rest.delete_rule(uid)
  end
  wait_until(seconds: 30, msg: 'Rules not empty') { Rest.rules.length.zero? }
end

def delete_items
  FileUtils.rm Dir.glob(File.join(items_dir, '*.items'))
  Rest.items.each do |item|
    Rest.set_item_state(item['name'], 'UNDEF')
    Rest.delete_item(item['name'])
  end
  wait_until(seconds: 30, msg: 'Items not empty') { Rest.items.length.zero? }
end
