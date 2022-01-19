# frozen_string_literal: true

require 'openhab/log/logger'
require 'openhab/dsl/rules/triggers/trigger'

module OpenHAB
  module DSL
    module Rules
      #
      # Module holds rule triggers
      #
      module Triggers
        #
        # Module for watching directories/files
        #

        #
        # Create a trigger to watch a path
        #
        # @param [String] path to watch
        #
        # @return [Trigger] Trigger object
        #
        def watch(path, glob: '*', for: %i[created deleted modified], attach: nil)
          glob, path = Watch.glob_for_path(Pathname.new(path), glob)
          types = [binding.local_variable_get(:for)].flatten
          config = { path: path.to_s, types: types.map(&:to_s), glob: glob.to_s }

          logger.state 'Creating a watch trigger', path: path, glob: glob, types: types
          Watch.new(rule_triggers: @rule_triggers).trigger(config: config, attach: attach)
        end

        #
        # Creates watch triggers
        #
        class Watch < Trigger
          # Characters in an fnmatch compatible glob
          GLOB_CHARS = ['**', '*', '?', '[', ']', '{', '}'].freeze
          private_constant :GLOB_CHARS

          #
          # Automatically creates globs for supplied paths if necessary
          # @param [Pathname] path to check
          # @param [String] specified glob
          #
          # @return [Pathname,String] Pathname to watch and glob to match
          def self.glob_for_path(path, glob)
            # Checks if the supplied pathname last element contains a glob char
            if GLOB_CHARS.any? { |char| path.basename.to_s.include? char }
              # Splits the supplied pathname into a glob string and parent path
              [path.basename.to_s, path.parent]
            elsif path.file? || !path.exist?
              # glob string matching end of Pathname and parent path
              ["*/#{path.basename}", path.parent]
            else
              [glob, path]
            end
          end

          #
          # Create a watch trigger based on item type
          #
          # @param [Array] commands to create trigger for
          # @param [Object] item to create trigger for
          #
          #
          def trigger(config:, attach:)
            append_trigger(type: WatchHandler::WATCH_TRIGGER_MODULE_ID,
                           config: config,
                           attach: attach)
          end
        end
      end
    end
  end
end
