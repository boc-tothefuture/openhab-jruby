# frozen_string_literal: true

require 'rake/packagetask'
require 'rubocop/rake_task'
require 'bundler/gem_tasks'
require 'yard'
require 'English'
require 'time'
require 'cucumber'
require 'cucumber/rake/task'
require 'open-uri'
require 'tty-command'
require 'process_exists'

require_relative 'lib/openhab/version'

PACKAGE_DIR = 'pkg'
TMP_DIR = 'tmp'
OPENHAB_DIR = File.join(TMP_DIR, 'openhab')
OPENHAB_VERSION = '3.0.0'
JRUBY_BUNDLE = File.realpath(Dir.glob('bundle/*.jar').first)
KARAF_CLIENT_PATH = File.join(OPENHAB_DIR, 'runtime/bin/client')
KARAF_CLIENT_ARGS = [KARAF_CLIENT_PATH, '-p', 'habopen'].freeze
KARAF_CLIENT = KARAF_CLIENT_ARGS.join(' ')

DEPLOY_DIR = File.join(OPENHAB_DIR, 'conf/automation/jsr223/ruby/personal')
LIB_DIR = File.join(OPENHAB_DIR, 'conf/automation/lib/ruby/lib/')
STATE_DIR = File.join(OPENHAB_DIR, 'rake_state')
CUCUMBER_LOGS = File.join(TMP_DIR, 'cucumber_logs')

CLEAN << PACKAGE_DIR
CLEAN << DEPLOY_DIR
CLEAN << CUCUMBER_LOGS

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb'] # optional
  t.stats_options = ['--list-undoc'] # optional
end

RuboCop::RakeTask.new(:lint) do |task|
  task.patterns = ['lib/**/*.rb', 'test/**/*.rb']
  task.fail_on_error = false
end

desc 'Run Cucumber Features'
task :features, [:feature] => ['openhab:warmup', 'openhab:deploy', CUCUMBER_LOGS] do |_, args|
  # Rake::Task['openhab:warmup'].execute
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--fail-fast --retry 5 --tags 'not @wip and not @not_implemented' --format pretty #{args[:feature]}"
    # t.cucumber_opts = "--tags 'not @wip and not @not_implemented' --format pretty #{args[:feature]}"
  end
end

namespace :gh do
  zip_path = ''

  directory PACKAGE_DIR

  desc 'Package for release'
  task package: [PACKAGE_DIR] do
    zip_filename = "OpenHABJRuby-#{OpenHAB::VERSION}.zip"
    zip_path = File.join(PACKAGE_DIR, zip_filename)
    target_dir = 'lib/'
    sh 'zip', '-r', zip_path, target_dir
  end

  desc 'Package for release'
  task release: :package do
    sh 'gh', 'release', 'create', OpenHAB::VERSION, '-p', '-F', 'CHANGELOG.md', zip_path, JRUBY_BUNDLE
  end
end

namespace :openhab do
  def command_success?(command)
    cmd = TTY::Command.new(printer: :null)
    cmd.run!(command).success?
  end

  def running?(fail_on_error: false)
    karaf_status = File.join(OPENHAB_DIR, 'runtime/bin/status')

    return false unless File.exist? karaf_status

    if fail_on_error
      fail_on_error(karaf_status)
      true
    else
      command_success? karaf_status
    end
  end

  # There can be a delay between when OpenHAB is running and ready to process commands
  def ready?(fail_on_error: false)
    return unless running?

    if fail_on_error
      fail_on_error("#{KARAF_CLIENT} 'system:version'")
      true
    else
      cmd = TTY::Command.new(printer: :null)
      cmd.run!("#{KARAF_CLIENT} 'system:version'").success?
    end
  end

  def ensure_openhab_running
    abort('Openhab not running') unless running?
  end

  def print_and_flush(string)
    print string
    $stdout.flush
  end

  def fail_on_error(command)
    cmd = TTY::Command.new
    out, = cmd.run(command, only_output_on_error: true)
    out
  end

  def karaf(command)
    fail_on_error("#{KARAF_CLIENT} '#{command}'")
  end

  def wait_for(duration, task)
    print_and_flush "Waiting for up to #{duration} seconds for #{task}"
    duration.times do
      if yield
        puts ''
        return true
      end

      print_and_flush '.'
      sleep 1
    end
    puts ''
    false
  end

  def ruby_env
    full_path = File.realpath OPENHAB_DIR
    { 'RUBYLIB' => File.join(full_path, '/conf/automation/lib/ruby/lib'),
      'GEM_HOME' => File.join(full_path, '/conf/automation/lib/ruby/gem_home') }
  end

  def state(task)
    Rake::Task[STATE_DIR.to_s].execute
    task_file = File.join(STATE_DIR, task)
    if File.exist? task_file
      puts "Skipping task(#{task}), task already up to date"
    else
      yield
      touch task_file
    end
  end

  directory OPENHAB_DIR
  directory DEPLOY_DIR
  directory LIB_DIR
  directory STATE_DIR
  directory CUCUMBER_LOGS

  desc 'Download Openhab and unzip it'
  task download: [OPENHAB_DIR] do |task|
    state(task.name) do
      openhab_zip = "openhab-#{OPENHAB_VERSION}.zip"
      Dir.chdir(OPENHAB_DIR) do
        puts "Downloading #{openhab_zip}"
        IO.copy_stream(open("https://openhab.jfrog.io/openhab/libs-release/org/openhab/distro/openhab/#{OPENHAB_VERSION}/openhab-#{OPENHAB_VERSION}.zip"), openhab_zip)
        fail_on_error("unzip #{openhab_zip}")
        rm openhab_zip
      end
    end
  end

  desc 'Add RubyLib and GEM_HOME to start.sh'
  task rubylib: :download do |task|
    state(task.name) do
      paths = ruby_env
      Dir.chdir(OPENHAB_DIR) do
        start_file = 'start.sh'

        settings = {
          /^export RUBYLIB=/ => "export RUBYLIB=#{paths['RUBYLIB']}\n",
          /^export GEM_HOME=/ => "export GEM_HOME=#{paths['GEM_HOME']}\n"
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
  end

  desc 'Install JRuby Bundle'
  task install: [:download, :rubylib, DEPLOY_DIR] do |task|
    state(task.name) do
      start
      if karaf('bundle:list --no-format org.openhab.automation.jrubyscripting').include?('Active')
        puts 'Bundle Active, no action taken'
      else
        unless karaf('bundle:list --no-format org.openhab.automation.jrubyscripting').include?('Installed')
          karaf("bundle:install file://#{JRUBY_BUNDLE}")
        end
        bundle_id = karaf('bundle:list --no-format org.openhab.automation.jrubyscripting').lines.last[/^\d\d\d/].chomp
        karaf("bundle:start #{bundle_id}")
      end
    end
  end

  desc 'Configure'
  task configure: %i[download] do |task|
    # Set log levels
    state(task.name) do
      start
      karaf('log:set TRACE jsr223')
      karaf('log:set TRACE org.openhab.core.automation')
      karaf('openhab:users add foo foo administrator')
      sh 'rsync', '-aih', 'config/userdata/', File.join(OPENHAB_DIR, 'userdata')
    end
  end

  def start
    if running?
      puts 'OpenHAB already running'
      return
    end

    env = ruby_env
    env = env.merge({ 'KARAF_REDIRECT' => File.join(File.realpath(TMP_DIR), 'karaf.log'),
                      'EXTRA_JAVA_OPTS' => '-Xmx4g'
      })

    Dir.chdir(OPENHAB_DIR) do
      puts 'Starting OpenHAB'
      pid = spawn(env, 'runtime/bin/start')
      Process.detach(pid)
    end

    wait_for(20, 'OpenHAB to start') { running? }
    abort 'Unable to start OpenHAB' unless running?(fail_on_error: true)

    wait_for(20, 'OpenHAB to become ready') { ready? }
    abort 'OpenHAB did not become ready' unless ready?(fail_on_error: true)

    puts 'OpenHAB started and ready'
  end

  desc 'Start OpenHAB'
  task start: %i[download] do
    start
  end

  def stop
    if running?
      pid = File.read(File.join(OPENHAB_DIR, 'userdata/tmp/karaf.pid')).chomp.to_i
      Dir.chdir(OPENHAB_DIR) do
        fail_on_error('runtime/bin/stop')
      end
      stopped = wait_for(20, 'OpenHAB to stop') { Process.exists?(pid) == false }
      abort 'Unable to stop OpenHAB' unless stopped
    end

    puts 'OpenHAB Stopped'
  end

  desc 'Stop OpenHAB'
  task :stop do
    stop
  end

  def restart
    puts 'Restarting OpenHAB'
    stop
    start
    puts 'OpenHAB Restarted'
  end

  desc 'Clobber local Openhab'
  task :clobber do
    stop if running?

    rm_rf OPENHAB_DIR
  end

  desc 'Warmup OpenHab environment'
  task warmup: [:prepare, DEPLOY_DIR] do
    start
    openhab_log = File.join(OPENHAB_DIR, 'userdata/logs/openhab.log')

    file = File.join('openhab_rules', 'warmup.rb')
    dest_file = File.join(DEPLOY_DIR, "#{File.basename(file, '.rb')}_#{Time.now.to_i}.rb")
    cp file, dest_file
    wait_for(20, 'OpenHAB to warmup') do
      File.foreach(openhab_log).grep(/OpenHAB warmup complete/).any?
    end
    rm dest_file
  end

  desc 'Prepare local Openhab'
  task prepare: [:download, :rubylib, :install, :configure, :deploy, CUCUMBER_LOGS]

  desc 'Setup local Openhab'
  task setup: %i[prepare stop]

  desc 'Deploy to local Openhab'
  task deploy: [:download, LIB_DIR] do
    fail_on_error("rsync --delete -aih lib/. #{LIB_DIR}")
  end

  desc 'Deploy adhoc test Openhab'
  task adhoc: :deploy do
    mkdir_p DEPLOY_DIR
    Dir.glob(File.join(DEPLOY_DIR, '*.rb')) { |file| rm file }
    Dir.glob(File.join('test/', '*.rb')) do |file|
      dest_name = "#{File.basename(file, '.rb')}_#{Time.now.to_i}.rb"
      cp file, File.join(deploy_dir, dest_name)
    end
  end
end
