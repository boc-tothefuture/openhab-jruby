# frozen_string_literal: true

# The following module patches the load path to include distributed ruby files
module PatchLoadPath
  lib_path = File.realpath(File.join(__dir__, '..'))
  $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)
end
