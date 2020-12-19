# frozen_string_literal: true

require 'openhab/configuration'
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
    Logging.logger(self.class.name)
  end

  class << self
    def logger(name)
      name ||= self.class.name
      @loggers[name] ||= Logging.logger_for(name)
    end

    def logger_for(classname)
      configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      log_prefix = Configuration.log_prefix
      log_prefix += if classname
                      ".#{classname}"
                    else
                      ".#{log_caller}"
                    end
      Logger.new(log_prefix)
    end

    def log_caller
      caller_locations.map(&:path)
                      .grep_v(%r{openhab/core/})
                      .grep_v(/rubygems/)
                      .grep_v(%r{lib/ruby})
                      .first
                      .yield_self { |caller| File.basename(caller, '.*') }
    end
 end

  # Addition
  def self.included(base)
    class << base
      def logger
        Logging.logger(self.class.name)
      end
    end
  end
end
