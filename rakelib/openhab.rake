# frozen_string_literal: true

require 'open-uri'
require 'tty-command'
require 'process_exists'
require 'erb'
require 'digest/md5'

# rubocop: disable Metrics/BlockLength
# Disabled due to part of buid / potentially refactor into classes
namespace :openhab do
  @openhab_version = '3.0.0'
  @jruby_bundle = 'https://github.com/boc-tothefuture/openhab2-addons/releases/download/3.1.0/org.openhab.automation.jrubyscripting-3.1.0-SNAPSHOT.jar'
  karaf_client_path = File.join(OPENHAB_DIR, 'runtime/bin/client')
  karaf_client_args = [karaf_client_path, '-p', 'habopen'].freeze
  @karaf_client = karaf_client_args.join(' ')
  @deploy_dir = File.join(OPENHAB_DIR, 'conf/automation/jsr223/ruby/personal')
  @state_dir = File.join(OPENHAB_DIR, 'rake_state')
  @services_config_file = File.join(OPENHAB_DIR, 'conf/services/jruby.cfg')

  CLOBBER << OPENHAB_DIR
  CLOBBER << @services_config_file
  CLOBBER << TMP_DIR
  CLEAN << @deploy_dir

  def command_success?(command)
    cmd = TTY::Command.new(:printer => :null)
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
      fail_on_error("#{@karaf_client} 'system:version'")
      true
    else
      cmd = TTY::Command.new(:printer => :null)
      cmd.run!("#{@karaf_client} 'system:version'").success?
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
    fail_on_error("#{@karaf_client} '#{command}'")
  end

  def wait_for(duration, task)
    print_and_flush "Waiting for up to #{duration} seconds for #{task}"
    duration.times do
      return true if yield

      print_and_flush '.'
      sleep 1
    end
    false
  ensure
    puts ''
  end

  def gem_home
    full_path = File.realpath OPENHAB_DIR
    File.join(full_path, '/conf/automation/lib/ruby/gem_home')
  end

  def ruby_env
    { 'GEM_HOME' => gem_home }
  end

  def state(task, args = nil)
    Rake::Task[@state_dir.to_s].execute
    task_file = File.join(@state_dir, task).gsub(':', '_')
    force = args&.key? :force
    if File.exist?(task_file) && !force
      puts "Skipping task(#{task}), task already up to date"
    else
      yield
      touch task_file
    end
  end

  directory OPENHAB_DIR
  directory @deploy_dir
  directory @state_dir
  directory CUCUMBER_LOGS

  desc 'Download Openhab and unzip it'
  task download: [OPENHAB_DIR] do |task|
    state(task.name) do
      openhab_zip = "openhab-#{@openhab_version}.zip"
      Dir.chdir(OPENHAB_DIR) do
        puts "Downloading #{openhab_zip}"
        IO.copy_stream(
          open('https://openhab.jfrog.io/openhab/libs-release/org/openhab/distro/openhab/'\
               "#{@openhab_version}/openhab-#{@openhab_version}.zip"), openhab_zip
        )
        fail_on_error("unzip #{openhab_zip}")
        rm openhab_zip
      end
    end
  end

  desc 'Setup services config'
  task :services, [:force] => [:download] do |task, args|
    state(task.name, args) do
      mkdir_p gem_home
      services_config = ERB.new <<~SERVICES
        org.openhab.automation.jrubyscripting:gem_home=<%= gem_home %>
      SERVICES
      File.write(@services_config_file, services_config.result)
    end
  end

  def bundle_id
    karaf('bundle:list --no-format org.openhab.automation.jrubyscripting').lines.last[/^\d\d\d/].chomp
  end

  desc 'Install JRuby Bundle'
  task bundle: [:download, :services, @deploy_dir] do |task|
    state(task.name) do
      start
      if karaf('bundle:list --no-format org.openhab.automation.jrubyscripting').include?('Active')
        puts 'Bundle Active, no action taken'
      else
        unless karaf('bundle:list --no-format org.openhab.automation.jrubyscripting').include?('Installed')
          karaf("bundle:install #{@jruby_bundle}")
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

  def karaf_log
    File.join(TMP_DIR, 'karaf.log')
  end

  def restart
    puts 'Restarting OpenHAB'
    stop
    start
    puts 'OpenHAB Restarted'
  end

  def wait_till_running
    wait_for(20, 'OpenHAB to start') { running? }
    abort 'Unable to start OpenHAB' unless running?(fail_on_error: true)

    wait_for(20, 'OpenHAB to become ready') { ready? }
    abort 'OpenHAB did not become ready' unless ready?(fail_on_error: true)
  end

  def openhab_env
    {
      'LANG' => ENV['LANG'],
      'JAVA_HOME' => ENV['JAVA_HOME'],
      'KARAF_REDIRECT' => karaf_log,
      'EXTRA_JAVA_OPTS' => '-Xmx4g'
    }
  end

  def start
    return puts 'OpenHAB already running' if running?

    Dir.chdir(OPENHAB_DIR) do
      puts 'Starting OpenHAB'
      # Running inside of bundler breaks GEM_HOME, so we run with a clean environment passing through
      # only specific variables
      pid = spawn(openhab_env, 'runtime/bin/start', unsetenv_others: true)
      Process.detach(pid)
    end
    wait_till_running
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
  task warmup: [:prepare, @deploy_dir, CUCUMBER_LOGS] do
    start
    openhab_log = File.join(OPENHAB_DIR, 'userdata/logs/openhab.log')

    file = File.join('openhab_rules', 'warmup.rb')
    dest_file = File.join(@deploy_dir, "#{File.basename(file, '.rb')}_#{Time.now.to_i}.rb")
    cp file, dest_file
    wait_for(20, 'OpenHAB to warmup') do
      File.foreach(openhab_log).grep(/OpenHAB warmup complete/).any?
    end
    rm dest_file
    cp openhab_log, File.join(CUCUMBER_LOGS, 'warmup.log')
    cp karaf_log, File.join(CUCUMBER_LOGS, 'karaf-warmup.log')
  end

  desc 'Prepare local Openhab'
  task prepare: [:download, :configure, :bundle, :deploy, CUCUMBER_LOGS]

  desc 'Setup local Openhab'
  task setup: %i[prepare stop]

  desc 'Deploy to local Openhab'
  task deploy: %i[download build] do |_task|
    mkdir_p gem_home
    gem_file = File.join(PACKAGE_DIR, "openhab-scripting-#{OpenHAB::VERSION}.gem")
    fail_on_error("gem install #{gem_file} -i #{gem_home} ")
  end

  desc 'Deploy adhoc test Openhab'
  task adhoc: [:deploy, @deploy_dir] do
    Dir.glob(File.join(@deploy_dir, '*.rb')) { |file| rm file }
    Dir.glob(File.join('test/', '*.rb')) do |file|
      dest_name = "#{File.basename(file, '.rb')}_#{Time.now.to_i}.rb"
      cp file, File.join(@deploy_dir, dest_name)
    end
  end
end

# rubocop: enable Metrics/BlockLength
