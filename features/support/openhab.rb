# frozen_string_literal: true

require_relative 'openhab_rest'
require 'English'
require 'singleton'
require 'tty-command'

Item = Struct.new(:type, :name, :state, :label, :groups, :group_type, :pattern, :function, :params, keyword_init: true)

def openhab_dir
  File.realpath 'tmp/openhab'
end

class OpenHABClient
  include Singleton

  def initialize
    karaf_client_path = File.join(openhab_dir, 'runtime/bin/client')
    @command = "#{karaf_client_path} -p habopen"
  end

  def command(command)
    reopen
    @io.write("#{command}\r\n")
    output = check_output
    output.slice!(0..command.length + 1)
    output.strip!
    output
  end

  def close
    @io&.close
    @io = nil
  end

  private

  def reopen
    close if @io&.wait_readable(0) && @io&.eof?
    return if @io

    @io = IO.popen(@command, 'r+')
    check_output
  end

  def check_output
    output = +''
    loop do
      @io.wait_readable
      raise "Running `#{@command}` failed with stdout: #{output}" if @io.eof?

      output << @io.readpartial(4096)
      if output.end_with?('openhab> ')
        output.slice!(-9..-1)
        return output
      end
    end
  end
end

def openhab_client(command)
  OpenHABClient.instance.command(command)
end

def items_dir
  File.join(openhab_dir, 'conf/items/')
end

def rules_dir
  File.join(openhab_dir, 'conf/automation/jsr223/ruby/personal/')
end

def ruby_lib_dir
  File.join(openhab_dir, 'conf/automation/lib/ruby/personal/')
end

def gem_home
  File.join(openhab_dir, 'conf/automation/lib/ruby/gem_home')
end

def services_dir
  File.join(openhab_dir, 'conf/services')
end

def openhab_log
  File.join(openhab_dir, 'userdata/logs/openhab.log')
end

def stop_openhab
  OpenHABClient.instance.close
  system('rake openhab:stop 1>/dev/null 2>/dev/null') || raise('Error Stopping OpenHAB')
end

def start_openhab
  system('rake openhab:start 1>/dev/null 2>/dev/null') || raise('Error Starting OpenHAB')
end

def clear_gem_path
  FileUtils.rm_r gem_home
  FileUtils.mkdir gem_home
end

def ensure_openhab_running
  cmd = TTY::Command.new(:printer => :null)
  cmd.run(File.join(openhab_dir, 'runtime/bin/status'), only_output_on_error: true)
end

def check_log(entry)
  lines = File.foreach(openhab_log).select { |line| line.include?('Error during evaluation of script') }
  if lines.any?
    log(lines)
    raise 'Error in script'
  end

  File.foreach(openhab_log).grep(/#{Regexp.escape(entry)}/).any?
end

def add_group(name:, group_type: nil, groups: nil, function: nil, params: nil)
  item = Item.new(type: 'Group', name: name, groups: groups, group_type: group_type, function: function, params: params)
  Rest.add_item(item: item)
end

def add_item(item:)
  Rest.add_item(item: item)
end

def truncate_log
  File.open(openhab_log, File::TRUNC)
end

def delete_things
  openhab_client('openhab:things clear')
end

def delete_rules
  FileUtils.rm Dir.glob(File.join(rules_dir, '*.rb'))

  deleted = false
  Rest.rules.each do |rule|
    uid = rule['uid']
    Rest.delete_rule(uid)
    deleted = true
  end
  return unless deleted

  wait_until(seconds: 30, msg: 'Rules not empty') { Rest.rules.length.zero? }
end

def delete_shared_libraries
  FileUtils.rm Dir.glob(File.join(ruby_lib_dir, '*.rb'))
end

def delete_items
  FileUtils.rm Dir.glob(File.join(items_dir, '*.items'))
  deleted = false
  Rest.items.each do |item|
    Rest.delete_item(item['name'])
    deleted = true
  end
  return unless deleted

  wait_until(seconds: 30, msg: 'Items not empty') { Rest.items.length.zero? }
end

def set_log_level(bundle, level)
  openhab_client("log:set #{level.upcase} #{bundle}")
end
