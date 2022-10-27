# frozen_string_literal: true

require "fileutils"

require_relative "openhab"

CUCUMBER_LOG_DIR = "tmp/cucumber_logs"

After do |scenario|
  FileUtils.mkdir_p CUCUMBER_LOG_DIR
  feature_log_file = File.join(CUCUMBER_LOG_DIR,
                               "#{File.basename(scenario.location.file)}_#{scenario.location.lines.first}")
  FileUtils.cp openhab_log, feature_log_file
end
