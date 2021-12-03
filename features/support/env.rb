# frozen_string_literal: true

# Execute these functions on start

require_relative 'openhab'

def openhab_deploy
  system('rake openhab:deploy 1>/dev/null 2>/dev/null') || raise('Error Deploying Libraries')
end

def prepare_openhab
  openhab_deploy
  ensure_openhab_running
end

After('@reset_library') do
  stop_openhab
  clear_gem_path
  openhab_deploy
  system('rake openhab:services[force] 1>/dev/null 2>/dev/null') || raise('Error Updating Services')
  start_openhab
end

After('@log_level_changed') do
  set_log_level('jsr223.jruby', 'TRACE')
  set_log_level('org.openhab.automation.jrubyscripting', 'TRACE')
  set_log_level('org.openhab.core.automation', 'TRACE')
end

prepare_openhab
