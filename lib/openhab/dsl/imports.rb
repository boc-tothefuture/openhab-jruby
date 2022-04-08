# frozen_string_literal: true

module OpenHAB
  module DSL
    include OpenHAB::Log
    #
    # Import required java classes
    #
    def self.import_presets # rubocop:disable Metrics/AbcSize
      return if Object.const_get(:ZonedDateTime).is_a?(Class)

      # Fix the import problem in OpenHAB 3.2 addon. Not required in 3.3+
      [java.time.Duration,
       java.time.ZonedDateTime,
       java.time.ZoneId,
       java.time.temporal.ChronoUnit].each do |klass|
        Object.const_set(klass.java_class.simple_name.to_sym, klass)
      end
    end
  end
end
