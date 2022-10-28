# frozen_string_literal: true

require "pathname"

module OpenHAB
  #
  # Return the OpenHAB conf directory as a ruby pathname
  #
  # @return [Pathname] OpenHAB conf path
  #
  # @!visibility private
  def self.conf_root
    Pathname.new(ENV["OPENHAB_CONF"])
  end
end
