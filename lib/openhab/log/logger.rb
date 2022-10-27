# frozen_string_literal: true

require "openhab/log/configuration"
require "java"

module OpenHAB
  module Core
    #
    # Ruby Logger that forwards messages at appropriate levels to OpenHAB Logger
    #
    class Logger
      java_import org.slf4j.LoggerFactory

      # @return [Array] Supported logging levels
      LEVELS = %i[trace debug warn info error].freeze
      private_constant :LEVELS

      #
      # Regex for matching internal calls in a stack trace
      #
      INTERNAL_CALL_REGEX = %r{(openhab-jrubyscripting-.*/lib)|org[./]jruby}.freeze
      private_constant :INTERNAL_CALL_REGEX

      #
      # Regex for matching internal calls in a java stack trace
      #
      EXCLUDED_JAVA_PACKAGES = /jdk\.internal\.reflect|java\.lang\.reflect|org\.openhab|java\.lang\.Thread\.run/.freeze
      private_constant :EXCLUDED_JAVA_PACKAGES

      #
      # Regex for matching internal calls in a java stack trace
      #
      JAVA_INTERNAL_CALL_REGEX = Regexp.union(INTERNAL_CALL_REGEX, EXCLUDED_JAVA_PACKAGES).freeze
      private_constant :JAVA_INTERNAL_CALL_REGEX

      #
      # Create a new logger
      #
      # @param [String] name of the logger
      #
      def initialize(name)
        @slf4j_logger = LoggerFactory.getLogger(name)
      end

      def name
        @slf4j_logger.name
      end

      def level
        Log.log_service.get_level(name)[name]&.downcase&.to_sym
      end

      def level=(level)
        Log.log_service.set_level(name, level.to_s)
      end

      # Dynamically define the methods for each level as identified by the levels constant
      # This creates a method for each level that looks like this
      # def <level>(msg=nil, &block)
      #   log(severity: <level>, msg: msg, &block)
      # end
      #
      # Also creates methods to check if the different logging levels are enabled
      #
      LEVELS.each do |level|
        define_method(level) do |msg = nil, &block|
          log(severity: level, msg: msg, &block)
        end
        define_method("#{level}?") { @slf4j_logger.send("is_#{level}_enabled") }
        # @deprecated
        alias_method "#{level}_enabled?", "#{level}?"
      end

      #
      # Logs a map of key(value) with an optional preamble at trace level
      # @param [String] preamble to put at start of log message
      # @param [Hash] kwargs key and values to log
      def state(preamble = "State:", **kwargs)
        return unless trace?

        states = kwargs.transform_keys(&:to_s)
                       .transform_keys(&:capitalize)
                       .transform_values { |v| v.nil? ? "nil" : v }
                       .map { |k, v| "#{k}(#{v})" }
                       .join(" ")
        trace "#{preamble} #{states}"
      end
      alias_method :states, :state

      #
      # Cleans the backtrace of an error to remove internal calls. If logging is set
      # to debug or lower, the full backtrace is kept
      #
      # @param [Exception] error An exception to be cleaned
      #
      # @return [Exception] the exception, potentially with a cleaned backtrace.
      #
      def clean_backtrace(error)
        return error if debug?

        if error.respond_to? :backtrace_locations
          backtrace = error.backtrace_locations.map(&:to_s).grep_v(INTERNAL_CALL_REGEX)
          error.set_backtrace(backtrace)
        elsif error.respond_to? :stack_trace
          backtrace = error.stack_trace.reject { |line| JAVA_INTERNAL_CALL_REGEX.match? line.to_s }
          error.set_stack_trace(backtrace)
        end
        error
      end

      #
      # Print error and stack trace without calls to internal classes
      #
      # @param [Exception] exception A rescued error
      # @param [String] rule_name The name of the rule where the exception occurred
      #
      def log_exception(exception, rule_name)
        exception = clean_backtrace(exception)
        error do
          "#{exception.message} (#{exception.class})\nIn rule: #{rule_name}\n#{exception.backtrace&.join("\n")}"
        end
      end

      private

      #
      # Log a message to the OpenHAB Logger
      #
      # @param [Symbol] severity Severity to log message at
      # @param [Object] msg to log, if no msg supplied and a block is provided,
      #   the msg is taken from the result of the block
      #
      def log(severity:, msg: nil)
        severity = severity.to_sym

        raise ArgumentError, "Unknown Severity #{severity}" unless LEVELS.include? severity

        # Dynamically check enablement of underlying logger
        return unless send("#{severity}?")

        # Process block if no message provided
        msg = yield if msg.nil? && block_given?

        @slf4j_logger.send(severity, msg.to_s)
      end
    end
  end

  #
  # Provides access to the OpenHAB logging using a Ruby logging methods
  #
  module Log
    module_function

    # Logger caches
    @loggers = {}

    # @!visibility private
    #
    # Add logger method to the object that includes this module
    #
    # @param [Object] base Object to add method to
    #
    #
    def self.included(base)
      class << base
        def logger
          Log.logger(self)
        end
      end
    end

    def root
      logger(org.slf4j.Logger::ROOT_LOGGER_NAME)
    end

    def events
      logger("openhab.event")
    end

    def logger(object = nil)
      return Log.logger(self) if object.nil?

      logger_name = object if object.is_a?(String)
      logger_name ||= logger_name(object)
      @loggers[logger_name] ||= Core::Logger.new(logger_name)
    end

    class << self
      #
      # Injects a logger into the base class
      #
      # @param [Object] object the logger is for
      #
      # @return [Logger] for the supplied name
      #
      def logger(object)
        # Cache logger instances for each object since construction
        # of logger name requires lots of operations and logger
        # names for some objects are specific to the class
        logger_name = logger_name(object)
        @loggers[logger_name] ||= Core::Logger.new(logger_name)
      end

      # @!visibility private
      def log_service
        @log_service = Core::OSGi.service("org.apache.karaf.log.core.LogService")
      end

      private

      # Construct the logger name from the supplied object
      # @param [Object] object to construct logger name from
      # @return name for logger based on object
      def logger_name(object)
        name = Configuration.log_prefix
        name += rules_file || ""
        name += rule_name  || ""
        name += klass_name(object) || ""
        name.tr_s(" ", "_").gsub("::", ".")
      end

      # Get the class name for the supplied object
      # @param [Object] object to derive class name for
      # @return [String] name of class for logging
      def klass_name(object)
        object = object.class unless object.is_a?(Class)
        object.then { |klass| java_klass(klass) }
              .then(&:name)
              .then { |name| filter_base_classes(name) }
              .then { |name| ".#{name}" unless name.nil? } # name is frozen in jruby 9.4
      end

      # Get the appropriate java class for the supplied klass if the supplied
      # class is a java class
      # @param [Class] klass to inspect
      # @return Class or Java class of supplied class
      def java_klass(klass)
        if klass.respond_to?(:java_class) &&
           klass.java_class &&
           !klass.java_class.name.start_with?("org.jruby.Ruby") &&
           !klass.java_class.name.start_with?("org.jruby.gen")
          klass = klass.java_class
        end
        klass
      end

      #
      # Returns the rules file name
      #
      def rules_file
        # Each rules file gets its own context
        # Set it once as a class value so that threads not
        # tied to a rules file pick up the rules file they
        # were spawned from
        @rules_file ||= log_caller&.downcase&.prepend(".")
      end

      # Get the name of the rule from the thread context
      def rule_name
        Thread.current[:RULE_NAME]&.downcase&.prepend(".")
      end

      # Filter out the base classes of Object and Module from the log name
      def filter_base_classes(klass_name)
        return nil if %w[Object Module].include?(klass_name)

        klass_name
      end

      #
      # Figure out the log prefix
      #
      # @return [String] Prefix for log messages
      #
      def log_caller
        caller_locations.map(&:path)
                        .grep_v(/rubygems|openhab-jrubyscripting|<script>/)
                        .first
                        .then { |caller| File.basename(caller, ".*") if caller }
      end
    end
  end
end
