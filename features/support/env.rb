# frozen_string_literal: true

# Execute these functions on start

require_relative "openhab"

def openhab_deploy
  system("rake openhab:deploy 1>/dev/null 2>/dev/null") || raise("Error Deploying Libraries")
end

def prepare_openhab
  openhab_deploy
  ensure_openhab_running
end

prepare_openhab
