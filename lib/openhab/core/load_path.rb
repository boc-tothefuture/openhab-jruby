# frozen_string_literal: true

module OpenHAB
  #
  # Core support for OpenHAB JRuby Library
  #
  module Core
    #
    # JRuby isn't respecting $RUBYLIB when run embedded inside of OpenHAB, so do it manually
    #
    def self.add_rubylib_to_load_path
      ENV["RUBYLIB"]&.split(File::PATH_SEPARATOR)&.each do |path|
        next if path.empty?

        $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
      end
    end
  end
end
