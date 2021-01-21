# frozen_string_literal: true

require 'core/log'

begin
  require 'bundler/inline'

  include Logging
  logger.debug('Bundler required')
rescue LoadError
  include Logging
  logger.debug('Bundler not found installing')

  begin
    require 'rubygems/commands/install_command'
    cmd = Gem::Commands::InstallCommand.new
    cmd.handle_options ['--no-document', 'bundler', '-v', '2.1.4']
    cmd.execute
    logger.debug('Bundler is installed')
    require 'bundler/inline'
  rescue Gem::SystemExitException => e
    if e.exit_code.zero?
      logger.debug('Bundler is installed')
      require 'bundler/inline'
    else
      logger.error("Error installing bundler, exit code: #{e}")
    end
  end
end
