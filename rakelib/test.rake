# frozen_string_literal: true

require 'cucumber'
require 'cucumber/rake/task'

desc 'Run Cucumber Features'
task :features, [:feature] => ['openhab:warmup', 'openhab:deploy', CUCUMBER_LOGS] do |_, args|
  Cucumber::Rake::Task.new(:features) do |t|
    cp File.join(OPENHAB_DIR, 'userdata/logs/openhab.log'), File.join(CUCUMBER_LOGS, 'startup.log')
    t.cucumber_opts = "--retry 3 --tags 'not @wip and not @not_implemented' --format pretty #{args[:feature]}"
  end
end
