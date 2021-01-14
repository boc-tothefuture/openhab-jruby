require_relative 'openhab'

After do |scenario|
  feature_log_file = File.join('tmp/cucumber_logs',
                               "#{File.basename(scenario.location.file)}_#{scenario.location.lines.first}")
  FileUtils.cp openhab_log, feature_log_file
end
