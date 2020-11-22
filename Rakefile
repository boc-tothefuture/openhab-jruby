# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'yard'

task default: %w[lint:auto_correct openhab]

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb'] # optional
  t.stats_options = ['--list-undoc'] # optional
end

RuboCop::RakeTask.new(:lint) do |task|
  task.patterns = ['lib/**/*.rb', 'test/**/*.rb', 'spec/**/*.rb']
  task.fail_on_error = false
end

RSpec::Core::RakeTask.new(:spec)

desc 'Deploy to local Openhab'
task :openhab do
  openhab_dir = '/Users/boc@us.ibm.com/personal/openhab-3/conf/automation/lib/ruby'
  puts `rsync -aih lib/openhab/.  #{openhab_dir}`
end

OPENHAB_DIR = 'tmp/openhab'
CLOBBER << OPENHAB_DIR

desc 'Download Openhab and unzip it'
task :openhab_download do
  mkdir_p OPENHAB_DIR
  Dir.chdir(OPENHAB_DIR) do
    `wget https://openhab.jfrog.io/openhab/libs-milestone-local/org/openhab/distro/openhab/3.0.0.M2/openhab-3.0.0.M2.zip`
    `unzip openhab-3.0.0.M2.zip`
  end
end

# desc 'Test using rspec'
# task :rspec do
#  sh %{/usr/local/bin/jruby -S rspec}
# end
