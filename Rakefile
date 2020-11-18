require 'rubocop/rake_task'
require "bundler/gem_tasks"

task default: %w[lint:auto_correct openhab]

RuboCop::RakeTask.new(:lint) do |task|
  task.patterns = ['lib/**/*.rb', 'test/**/*.rb']
  task.fail_on_error = false
end


openhab_dir = '/Users/boc@us.ibm.com/personal/openhab-3/conf/automation/lib/ruby'

desc 'Deploy to local Openhab'
task :openhab do
    rm_r  Dir.glob("#{openhab_dir}/*")
    cp_r 'lib/openhab/.', openhab_dir, verbose: true
end
