# frozen_string_literal: true

require 'find'

# core_bundles = File.join(__dir__, '../tmp/openhab/runtime/system/org/openhab/core/bundles/')
system_bundles = File.join(__dir__, '../tmp/openhab/runtime/system/')

# jar_dirs = [system_bundles]
Find.find(system_bundles) do |path|
  if File.basename(path).end_with?('.jar')
    $CLASSPATH << path unless $CLASSPATH.include? path
  end
end
