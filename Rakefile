# frozen_string_literal: true

require 'rake/packagetask'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'yard'
require 'English'
require 'time'
require 'cucumber'
require 'cucumber/rake/task'
require 'open-uri'
require_relative 'lib/openhab/version'

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

desc 'Run Cucumber Features'
task features: 'openhab:setup' do
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = '--tags "not @wip and not @not_implemented" --format pretty' # Any valid command line option can go here.
  end
end

PACKAGE_DIR = 'pkg'
OPENHAB_PATH = 'tmp/openhab'
mkdir_p OPENHAB_PATH
OPENHAB_DIR = File.realpath OPENHAB_PATH
CLOBBER << OPENHAB_DIR
CLEAN << PACKAGE_DIR

OPENHAB_VERSION = '3.0.0.RC2'
JRUBY_BUNDLE = File.realpath(Dir.glob('bundle/*.jar').first)

zip_path = ''
desc 'Package for release'
task :package do
  mkdir_p PACKAGE_DIR
  zip_filename = "OpenHABJRuby-#{OpenHAB::VERSION}.zip"
  zip_path = File.join(PACKAGE_DIR, zip_filename)
  target_dir = 'lib/'
  sh 'zip', '-r', zip_path, target_dir
end

namespace :gh do
  desc 'Package for release'
  task release: :package do
    sh 'gh', 'release', 'create', OpenHAB::VERSION, '-p', '-F', 'CHANGELOG.md', zip_path, JRUBY_BUNDLE
  end
end

namespace :openhab do
  karaf_client_path = File.join(OPENHAB_DIR, 'runtime/bin/client')
  karaf_client_args = [karaf_client_path, '-p', 'habopen']
  karaf_client = karaf_client_args.join(' ')

  def ensure_openhab_running
    karaf_status = File.join(OPENHAB_DIR, 'runtime/bin/status')
    `#{karaf_status}`
    abort('Openhab not running') unless $CHILD_STATUS == 0
  end

  desc 'Download Openhab and unzip it'
  task :download do
    mkdir_p OPENHAB_DIR
    next if File.exist? File.join(OPENHAB_DIR, 'start.sh')

    Dir.chdir(OPENHAB_DIR) do
      IO.copy_stream(open("https://openhab.jfrog.io/openhab/libs-milestone-local/org/openhab/distro/openhab/#{OPENHAB_VERSION}/openhab-#{OPENHAB_VERSION}.zip"), "openhab-#{OPENHAB_VERSION}.zip")
      sh 'unzip', "openhab-#{OPENHAB_VERSION}"
    end
  end

  desc 'Add RubyLib and Gem_HOME to start.sh'
  task rubylib: :download do
    Dir.chdir(OPENHAB_DIR) do
      start_file = 'start.sh'

      settings = {
        /^export RUBYLIB=/ => "export RUBYLIB=#{File.join OPENHAB_DIR, '/conf/automation/lib/ruby/lib'}\n",
        /^export GEM_HOME=/ => "export GEM_HOME=#{File.join OPENHAB_DIR, '/conf/automation/lib/ruby/gem_home'}\n"
      }

      settings.each do |regex, line|
        lines = File.readlines(start_file)
        unless lines.grep(regex).any?
          lines.insert(-2, line)
          File.write(start_file, lines.join)
        end
      end
    end
  end

  desc 'Install JRuby Bundle'
  task install: %i[download rubylib] do
    ensure_openhab_running
    Dir.chdir(OPENHAB_DIR) do
      if `#{karaf_client} "bundle:list --no-format org.openhab.automation.jrubyscripting"`.include?('Active')
        puts 'Bundle Active, no action taken'
      else
        unless `#{karaf_client} "bundle:list --no-format org.openhab.automation.jrubyscripting"`.include?('Installed')
          `#{karaf_client} bundle:install file://#{JRUBY_BUNDLE}`
        end
        bundle_id = `#{karaf_client} "bundle:list --no-format org.openhab.automation.jrubyscripting"`.lines.last[/^\d\d\d/].chomp
        `#{karaf_client} bundle:start #{bundle_id}`
      end

      mkdir_p 'conf/automation/jsr223/ruby/personal/'
    end
  end

  desc 'Configure'
  task configure: [:download] do
    # Set log levels
    ensure_openhab_running
    sh(*karaf_client_args, 'log:set TRACE jsr223')
    sh(*karaf_client_args, 'log:set TRACE org.openhab.core.automation')
    sh(*karaf_client_args, 'openhab:users add foo foo administrator')
    sh 'rsync', '-aih', 'config/userdata/', File.join(OPENHAB_DIR, 'userdata')
  end

  desc 'Start OpenHAB'
  task :start do
    Dir.chdir(OPENHAB_DIR) do
      pid = spawn('./start.sh')
      Process.detach(pid)
    end
  end

  desc 'Stop OpenHAB'
  task :stop do
    Dir.chdir(OPENHAB_DIR) do
      sh('runtime/bin/stop')
    end
  end

  desc 'Setup local Openhab'
  task setup: %i[download rubylib install configure]

  desc 'Deploy to local Openhab'
  task deploy: :download do
    deploy_dir = File.join(OPENHAB_DIR, 'conf/automation/lib/ruby/lib/')
    mkdir_p deploy_dir
    sh 'rsync', '--delete', '-aih', 'lib/.', deploy_dir
  end

  desc 'Deploy adhoc test Openhab'
  task adhoc: :deploy do
    deploy_dir = File.join(OPENHAB_DIR, 'conf/automation/jsr223/ruby/personal')
    mkdir_p deploy_dir
    Dir.glob(File.join(deploy_dir, '*.rb')) { |file| rm file }
    Dir.glob(File.join('test/', '*.rb')) do |file|
      dest_name = "#{File.basename(file, '.rb')}_#{Time.now.to_i}.rb"
      cp file, File.join(deploy_dir, dest_name)
    end
  end
end
