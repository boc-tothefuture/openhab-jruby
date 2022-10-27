# frozen_string_literal: true

module OpenHAB
  module RSpec
    module Configuration
      class << self
        # Copy binding configuration from the root OpenHAB instance
        # Default `true`
        # @return [true, false]
        attr_accessor :include_bindings
        # Copy the JSONDB (managed thing and item configuration) from the root
        # OpenHAB instance
        # Default `true`
        # @return [true, false]
        attr_accessor :include_jsondb
        # Use a private (empty) confdir (scripts, rules, items, and things
        # # files), instead of sharing with the root OpenHAB
        # instance.
        # Default `false`
        # @return [true, false]
        attr_accessor :private_confdir
        # Use the root OpenHAB instance directly, rather than creating a
        # private (but linked) instance.
        # @default `false`
        # @return [true, false]
        attr_accessor :use_root_instance
      end

      self.include_bindings = true
      self.include_jsondb = true
      self.private_confdir = false
      self.use_root_instance = false
    end
  end
end
