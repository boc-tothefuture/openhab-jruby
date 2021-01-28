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
require 'cuke_linter'
require 'erb'

require_relative 'lib/openhab/version'

PACKAGE_DIR = 'pkg'
TMP_DIR = 'tmp'
OPENHAB_DIR = File.join(TMP_DIR, 'openhab')
DOCS_DIR = 'doc'
OPENHAB_VERSION = '3.0.0'
JRUBY_BUNDLE = 'https://github.com/boc-tothefuture/openhab2-addons/releases/download/3.1.0/org.openhab.automation.jrubyscripting-3.1.0-SNAPSHOT.jar'
KARAF_CLIENT_PATH = File.join(OPENHAB_DIR, 'runtime/bin/client')
KARAF_CLIENT_ARGS = [KARAF_CLIENT_PATH, '-p', 'habopen'].freeze
KARAF_CLIENT = KARAF_CLIENT_ARGS.join(' ')

DEPLOY_DIR = File.join(OPENHAB_DIR, 'conf/automation/jsr223/ruby/personal')
LIB_DIR = File.join(OPENHAB_DIR, 'conf/automation/lib/ruby/lib/')
STATE_DIR = File.join(OPENHAB_DIR, 'rake_state')
YARD_DIR = File.join('docs', 'yard')
CUCUMBER_LOGS = File.join(TMP_DIR, 'cucumber_logs')
SERVICES_CONFIG = File.join(OPENHAB_DIR, 'conf/services/jruby.cfg')

CLEAN << PACKAGE_DIR
CLEAN << DEPLOY_DIR
CLEAN << CUCUMBER_LOGS
CLEAN << YARD_DIR
CLEAN << '.yardoc'

CLOBBER << OPENHAB_DIR

desc 'Generate Yard docs'
task :yard do
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb'] # optional
    t.stats_options = ['--list-undoc'] # optional
  end
end

RuboCop::RakeTask.new do |task|
  task.patterns = ['lib/**/*.rb', 'test/**/*.rb']
  task.fail_on_error = false
end

desc 'Lint Code'
task :lint do
  Rake::Task['rubocop'].invoke
  CukeLinter.lint
end

desc 'Start Documentation Server'
task docs: :yard do
  sh 'bundle exec jekyll clean'
  sh 'bundle exec jekyll server --config docs/_config.yml'
end

task :yard_server do
  sh 'bundle exec guard'
end

desc 'Run Cucumber Features'
task :features, [:feature] => ['openhab:warmup', 'openhab:deploy', CUCUMBER_LOGS] do |_, args|
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--tags 'not @wip and not @not_implemented' --format pretty #{args[:feature]}"
  end
end

desc 'Get OpenHAB-JRuby Version'
task :version do
  puts OpenHAB::VERSION
end

namespace :gh do
  desc 'Release JRuby Binding'
  task :release,  [:file] do |_, args|
    bundle = args[:file]
    _,version,_ = File.basename(bundle,'.jar').split('-')
    sh 'gh', 'release', 'delete', version, '-y', '-R', 'boc-tothefuture/openhab2-addons'
    sh 'gh', 'release', 'create', version, '-p', '-t', 'JRuby Binding Prerelease', '-n', 'Prerelease', '-R', 'boc-tothefuture/openhab2-addons', bundle
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

  def fail_on_error(command, env = {})
    cmd = TTY::Command.new
    out, = cmd.run(command, env: env, only_output_on_error: true)
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

  def gem_home
    full_path = File.realpath OPENHAB_DIR
    File.join(full_path, '/conf/automation/lib/ruby/gem_home')
  end

  def ruby_env
    { 'GEM_HOME' => gem_home }
  end

  def state(task, args = nil)
    Rake::Task[STATE_DIR.to_s].execute
    task_file = File.join(STATE_DIR, task)
    force = args&.key? :force
    if File.exist?(task_file) && !force
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
        IO.copy_stream(
          open("https://openhab.jfrog.io/openhab/libs-release/org/openhab/distro/openhab/#{OPENHAB_VERSION}/openhab-#{OPENHAB_VERSION}.zip"), openhab_zip
        )
        fail_on_error("unzip #{openhab_zip}")
        rm openhab_zip
      end
    end
  end

  desc 'Setup services config'
  task :services, [:force] => [:download] do |task, args|
    state(task.name, args) do
      services_config = ERB.new <<~SERVICES
        org.openhab.automation.jrubyscripting:gem_home=<%= gem_home %>
      SERVICES
      File.write(SERVICES_CONFIG, services_config.result)
    end
  end

  def bundle_id
    karaf('bundle:list --no-format org.openhab.automation.jrubyscripting').lines.last[/^\d\d\d/].chomp
  end

  desc 'Install JRuby Bundle'
  task bundle: [:download, :services, DEPLOY_DIR] do |task|
    state(task.name) do
      start
      if karaf('bundle:list --no-format org.openhab.automation.jrubyscripting').include?('Active')
        puts 'Bundle Active, no action taken'
      else
        unless karaf('bundle:list --no-format org.openhab.automation.jrubyscripting').include?('Installed')
          karaf("bundle:install #{JRUBY_BUNDLE}")
        end
        karaf("bundle:start #{bundle_id}")
      end
    end
  end

  desc 'Upgrade JRuby Bundle'
  task :upgrade, [:file] do |_, args|
    start
    if karaf('bundle:list --no-format org.openhab.automation.jrubyscripting').include?('Active')
      karaf("bundle:update #{bundle_id} file://#{args[:file]}")
    else
      abort "Bundle not installed, can't upgrade"
    end
  end

  desc 'Configure'
  task configure: %i[download] do |task|
    # Set log levels
    state(task.name) do
      start
      karaf('log:set TRACE jsr223')
      karaf('log:set TRACE org.openhab.core.automation')
      karaf('log:set TRACE org.openhab.binding.jrubyscripting')
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
                      'EXTRA_JAVA_OPTS' => '-Xmx4g' })

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

  desc 'Create a Dev Dump in OpenHAB and wait until its complete'
  task :dump do
    dumps = File.join(OPENHAB_DIR, 'userdata', '*.zip')

    puts 'Deleting any existing dumps'
    dump = Dir[dumps].each { |dump_file| rm dump_file }

    karaf('dev:dump-create')

    wait_for(30, 'Dump to be created') do
      Dir[dumps].any?
    end
    dump = Dir[dumps].first
    puts "Found dev dump #{dump}"
    dump_sizes = Array.new(10)
    wait_for(120, 'Dump size to not increase for 10 seconds') do
      dump_sizes << File.size(dump)
      dump_sizes.last(10).uniq.length == 1
    end
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
  task prepare: [:download, :configure, :bundle, :deploy, CUCUMBER_LOGS]

  desc 'Setup local Openhab'
  task setup: %i[prepare stop]

  desc 'Deploy to local Openhab'
  task deploy: %i[download build] do |_task|
    gem_file = File.join(PACKAGE_DIR, "openhab-scripting-#{OpenHAB::VERSION}.gem")
    fail_on_error("gem install #{gem_file}", ruby_env)
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
