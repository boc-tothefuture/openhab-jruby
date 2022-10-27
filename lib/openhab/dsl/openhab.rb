# frozen_string_literal: true

require "pathname"

module OpenHAB
  #
  # Return the OpenHAB conf directory as a ruby pathname
  #
  # @return [Pathname] OpenHAB conf path
  #
  def self.conf_root
    Pathname.new(ENV["OPENHAB_CONF"])
  end

  module DSL
    #
    # Provides access to OpenHAB attributes
    #
    module Core
      include OpenHAB::Log

      module_function

      # @deprecated Please use {OpenHAB.conf_root} instead
      def __conf__
        OpenHAB.conf_root
      end
    end
  end
end
