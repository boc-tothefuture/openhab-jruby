# frozen_string_literal: true

require 'cucumber'
require 'cucumber/rake/task'

desc 'Run Cucumber Features'
task features: ['openhab:warmup', 'openhab:deploy', CUCUMBER_LOGS] do |_, args|
  Cucumber::Rake::Task.new(:features) do |t|
    features = args.extras.join(' ')
    cp File.join(OPENHAB_DIR, 'userdata/logs/openhab.log'), File.join(CUCUMBER_LOGS, 'startup.log')
    t.cucumber_opts = "--tags 'not @wip and not @not_implemented' --format pretty #{features}"
  end
end
