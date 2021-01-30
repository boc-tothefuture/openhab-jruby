# frozen_string_literal: true

#
# Holds project version constant
#
module OpenHAB
  # @return [String] Version of OpenHAB helper libraries
  VERSION = File.read(File.join(__dir__, 'VERSION'))
end
