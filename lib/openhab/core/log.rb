# frozen_string_literal: true

require 'configuration'
require 'java'
require 'pp'

module Logging
  class Logger
    java_import org.slf4j.LoggerFactory

    LEVELS = %i[TRACE DEBUG WARN INFO ERROR].freeze

    def initialize(name)
      @sl4fj_logger = LoggerFactory.getLogger(name)
    end

    def message_to_string(msg:)
      case msg
      when ::String
        msg
      when ::Exception
        "#{msg.message} (#{msg.class})\n#{msg.backtrace&.join("\n")}"
      else
        msg.inspect
      end
    end

    def log(severity:, msg: nil)
      severity = severity.to_sym

      raise "Unknown Severity #{severity}" unless LEVELS.include? severity

      # Dynamically check enablement of underlying logger, this expands to "is_<level>_enabled"
      return unless @sl4fj_logger.send("is_#{severity.to_s.downcase}_enabled")

      # Process block if no message provided
      if msg.nil?
        if block_given?
          msg = yield
        else
          return
        end
      end

      msg = message_to_string(msg: msg)

      # Dynamically invoke underlying logger, this expands to "<level>(message)"
      @sl4fj_logger.send(severity.to_s.downcase, msg)
    end

    # Dynamically define the methods for each level as identified by the levels constant
    # This creates a method for each level that looks like this
    # def <level>(msg=nil, &block)
    #   log(severity: <level>, msg: msg, &block)
    # end
    LEVELS.each do |level|
      method = level.to_s.downcase
      define_method(method.to_s) do |msg = nil, &block|
        log(severity: level, msg: msg, &block)
      end
    end
  end

  @loggers = {}

  # Return a logger with the configured log prefix plus the calling scripts name

  def logger
    Logging.logger
  end

  class << self
    def logger
      @logger ||= Logging.logger_for(self.class.name)
    end

    def logger_for(classname)
      @loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(_classname)
      log_prefix = Configuration.log_prefix
      log_caller = File.basename(caller_locations.first.path, '.*')
      log_prefix += ".#{log_caller}" unless log_caller == 'log'
      Logger.new(log_prefix)
    end
 end

  # Addition
  def self.included(base)
    class << base
      def logger
        Logging.logger
      end
    end
  end
end
