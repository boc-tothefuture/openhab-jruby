# frozen_string_literal: true

module OpenHAB
  #
  # Provides access to the OpenHAB logging facilities using Ruby logging methods
  #
  module Log
    # @!visibility private
    def self.included(base)
      return if base.singleton_class?

      base.singleton_class.include(self)
    end

    #
    # Retrieve the {Logger} for this class.
    #
    # @return [Logger]
    #
    def logger
      if equal?(Object)
        # can't cache, because the logger for `main` will change
        # depending on rule context
        return Log.logger(self)
      end

      return @logger ||= Log.logger(self) if equal?(self.class) || is_a?(Module) || equal?(Object)

      self.class.logger
    end

    @loggers = {}
    class << self
      #
      # Retrieve a {Logger} for a particular object.
      #
      # @param [Module,String] object Object the logger is for, or explicit name of the logger.
      # @return [Logger]
      #
      def logger(object)
        case object
        when Module
          name = Logger::PREFIX
          klass = java_klass(object)
          name += ".#{klass.name.gsub("::", ".")}" if klass.name
        when String
          name = object
        end
        if object.equal?(Object)
          name = "#{Logger::PREFIX}.#{(rule_uid || rules_file).tr_s(":", "_")
          .gsub(/[^A-Za-z0-9_.-]/, "")}"
        end

        @loggers[name] ||= Logger.new(name)
      end

      private

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

      def rules_file
        # Each rules file gets its own context
        # Set it once as a class value so that threads not
        # tied to a rules file pick up the rules file they
        # were spawned from
        @rules_file ||= log_caller
      end

      # Get the id of the rule from the thread context
      def rule_uid
        Thread.current[:OPENHAB_RULE_UID]
      end

      #
      # Figure out the log prefix
      #
      # @return [String] Prefix for log messages
      #
      def log_caller
        caller_locations.map(&:path)
                        .grep_v(%r{rubygems|openhab-jrubyscripting|<script>|gems/(?:irb|bundler)-|/\.irbrc})
                        .first
                        .then { |caller| File.basename(caller, ".*") if caller }
      end
    end
    rules_file # load this immediately
  end

  #
  # Ruby Logger that forwards messages at appropriate levels to OpenHAB Logger
  #
  class Logger
    # The base prefix for all loggers from this gem.
    PREFIX = "org.openhab.automation.jrubyscripting"

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

    class << self
      # The root logger (all of OpenHAB)
      # @return [Logger]
      def root
        Log.logger(org.slf4j.Logger::ROOT_LOGGER_NAME)
      end

      # The root logger for this gem
      # @return [Logger]
      def gem_root
        Log.logger(PREFIX)
      end

      # The events logger (events.log)
      # @return [Logger]
      def events
        Log.logger("openhab.event")
      end

      # @!visibility private
      def log_service
        @log_service = Core::OSGi.service("org.apache.karaf.log.core.LogService")
      end

      private

      # @!macro def_level_method
      #   @!method $1(msg = nil)
      #
      #   Log a message at $1 level.
      #
      #   @param msg [Object, nil] The log message
      #   @yield
      #     Pass a block to delay generating the log message until it's
      #     confirmed that logging is enabled at $1 level.
      #   @yieldreturn [Object, nil] The log message
      #   @return [void]
      #
      def def_level_method(level)
        define_method(level) do |msg = nil, &block|
          log(severity: level, msg: msg, &block)
        end
      end

      # @!macro def_level_predicate
      #   @!method $1?
      #
      #   If the logger is enabled at $1 level.
      #
      #   @return [true,false]
      #
      def def_level_predicate(level)
        define_method("#{level}?") { @slf4j_logger.send("is_#{level}_enabled") }
      end
    end

    # @!visibility private
    #
    # Create a new logger
    #
    # @param [String] name of the logger
    #
    def initialize(name)
      @slf4j_logger = org.slf4j.LoggerFactory.getLogger(name)
    end

    # The logger name
    # @return [String]
    def name
      @slf4j_logger.name
    end

    # @return [String]
    def inspect
      "#<OpenHAB::Logger #{name}>"
    end
    alias_method :to_s, :inspect

    # @!attribute [rw] level
    # @return [:error,:warn,:info,:debug,:trace] The current log level
    def level
      Logger.log_service.get_level(name)[name]&.downcase&.to_sym
    end

    def level=(level)
      Logger.log_service.set_level(name, level.to_s)
    end

    def_level_method(:error)
    def_level_predicate(:error)
    def_level_method(:warn)
    def_level_predicate(:warn)
    def_level_method(:info)
    def_level_predicate(:info)
    def_level_method(:debug)
    def_level_predicate(:debug)
    def_level_method(:trace)
    def_level_predicate(:trace)

    #
    # Print error and stack trace without calls to internal classes
    #
    # @param [Exception] exception A rescued error
    # @param [String] rule_name The name of the rule where the exception occurred
    # @return [void]
    #
    def log_exception(exception, rule_name)
      exception = clean_backtrace(exception)
      error do
        "#{exception.message} (#{exception.class})\nIn rule: #{rule_name}\n#{exception.backtrace&.join("\n")}"
      end
    end

    private

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
    # Log a message to the OpenHAB Logger
    #
    # @param [Symbol] severity Severity to log message at
    # @param [Object] msg to log, if no msg supplied and a block is provided,
    #   the msg is taken from the result of the block
    #
    def log(severity:, msg: nil)
      raise ArgumentError, "Unknown Severity #{severity}" unless LEVELS.include? severity

      # Dynamically check enablement of underlying logger
      return unless send("#{severity}?")

      # Process block if no message provided
      msg = yield if msg.nil? && block_given?

      @slf4j_logger.send(severity, msg.to_s)
    end
  end
end
