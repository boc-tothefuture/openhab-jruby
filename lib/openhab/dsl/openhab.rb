# frozen_string_literal: true

require 'pathname'

module OpenHAB
  module DSL
    #
    # Provides access to OpenHAB attributes
    #
    module Core
      include OpenHAB::Log

      module_function

      #
      # Return the OpenHAB conf directory as a ruby pathname
      #
      # @return [Pathname] OpenHAB conf path
      #
      def __conf__
        Pathname.new(ENV['OPENHAB_CONF'])
      end
    end
  end
end
