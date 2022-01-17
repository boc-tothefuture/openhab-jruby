# frozen_string_literal: true

require 'java'
require 'openhab/log/logger'
require 'openhab/core/services'

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
        module Watch
          include OpenHAB::Log

          # Characters in an fnmatch compatible glob
          GLOB_CHARS = ['**', '*', '?', '[', ']', '{', '}'].freeze

          #
          # Creates trigger types and trigger type factories for OpenHAB
          #
          def self.add_watch_handler
            java_import org.openhab.core.automation.type.TriggerType
            OpenHAB::Core.automation_manager.add_trigger_handler(
              OpenHAB::DSL::Rules::Triggers::Watch::WATCH_TRIGGER_MODULE_ID,
              OpenHAB::DSL::Rules::Triggers::Watch::WatchTriggerHandlerFactory.new
            )

            OpenHAB::Core.automation_manager.add_trigger_type(watch_trigger_type)
            OpenHAB::Log.logger(self).trace('Added watch trigger handler')
          end

          #
          # Creates trigger types and trigger type factories for OpenHAB
          #
          private_class_method def self.watch_trigger_type
            TriggerType.new(
              OpenHAB::DSL::Rules::Triggers::Watch::WATCH_TRIGGER_MODULE_ID,
              nil,
              'A path change event is detected',
              'Triggers when a path change event is detected',
              nil,
              org.openhab.core.automation.Visibility::VISIBLE,
              nil
            )
          end

          # Struct for Watch Events
          WatchEvent = Struct.new(:type, :path, :attachment)

          # Trigger ID for Watch Triggers
          WATCH_TRIGGER_MODULE_ID = 'jsr223.jruby.WatchTrigger'

          # Extends the OpenHAB watch service to watch directories
          #
          # Must match java method name style
          # rubocop:disable Naming/MethodName
          class Watcher < org.openhab.core.service.AbstractWatchService
            java_import java.nio.file.StandardWatchEventKinds

            # Hash of event symbols as strings to map to NIO events
            STRING_TO_EVENT = {
              created: StandardWatchEventKinds::ENTRY_CREATE,
              deleted: StandardWatchEventKinds::ENTRY_DELETE,
              modified: StandardWatchEventKinds::ENTRY_MODIFY
            }.transform_keys(&:to_s).freeze

            # Hash of NIO event kinds to ruby symbols
            EVENT_TO_SYMBOL = STRING_TO_EVENT.invert.transform_values(&:to_sym).freeze

            # Creates a new Watch Service
            def initialize(path, types, &block)
              super(path)
              @types = types.map { |type| STRING_TO_EVENT[type] }
              @block = block
            end

            # Invoked by java super class to get type of events to watch for
            # @param [String] _path ignored
            #
            # @return [Array] array of NIO event kinds
            def getWatchEventKinds(_path)
              @types
            end

            # Invoked by java super class to check if sub directories should be watched
            # @return [false] false
            def watchSubDirectories
              false
            end

            # Invoked by java super class when an watch event occurs
            # @param [String] _event ignored
            # @param [StandardWatchEventKind] kind NIO watch event kind
            # @param [java.nio.Path] Path that had an event
            def processWatchEvent(_event, kind, path)
              @block.call(WatchEvent.new(EVENT_TO_SYMBOL[kind], Pathname.new(path.to_s)))
            end
          end
          # rubocop:enable Naming/MethodName

          # Implements the OpenHAB TriggerHandler interface to process Watch Triggers
          class WatchTriggerHandler
            include OpenHAB::Log
            include org.openhab.core.automation.handler.TriggerHandler

            # Creates a new WatchTriggerHandler
            # @param [Trigger] OpenHAB trigger associated with handler
            #
            def initialize(trigger)
              @trigger = trigger
              config = trigger.configuration.properties.to_hash.transform_keys(&:to_sym)
              @path = config[:path]
              @watcher = Watcher.new(@path, config[:types], &watch_event_handler(config[:glob]))
              @watcher.activate
              logger.trace("Created watcher for #{@path}")
            end

            # Create a lambda to use to invoke rule engine when file watch notification happens
            # @param [String] glob to match for notification events
            #
            # @return [Lambda] lambda to execute on notification events
            #
            def watch_event_handler(glob)
              lambda { |watch_event|
                logger.trace("Received event(#{watch_event})")
                if watch_event.path.fnmatch?(glob)
                  @rule_engine_callback&.triggered(@trigger, { 'event' => watch_event })
                else
                  logger.trace("Event #{watch_event} did not match glob(#{glob})")
                end
              }
            end

            # Called by OpenHAB to set the rule engine to invoke when triggered
            # Must match java method name style
            def setCallback(callback) # rubocop:disable Naming/MethodName
              @rule_engine_callback = callback
            end

            #
            # Dispose of handler which deactivates watcher
            #
            def dispose
              logger.trace("Deactivating watcher for #{@path}")
              @watcher&.deactivate
            end
          end

          # Implements the ScriptedTriggerHandlerFactory interface to create a new Trigger Handler
          class WatchTriggerHandlerFactory
            include org.openhab.core.automation.module.script.rulesupport.shared.factories.ScriptedTriggerHandlerFactory

            # Invoked by the OpenHAB core to get a trigger handler for the supllied trigger
            # @param [Trigger] OpenHAB trigger
            #
            # @return [WatchTriggerHandler] trigger handler for supplied trigger
            def get(trigger)
              WatchTriggerHandler.new(trigger)
            end
          end
        end

        #
        # Create a trigger to watch a path
        #
        # @param [String] path to watch
        #
        # @return [Trigger] Trigger object
        #
        def watch(path, glob: '*', for: %i[created deleted modified], attach: nil)
          glob, path = glob_for_path(Pathname.new(path), glob)
          types = [binding.local_variable_get(:for)].flatten
          conf = { path: path.to_s, types: types.map(&:to_s), glob: glob.to_s }

          logger.trace("Creating a watch trigger for path(#{path}) with glob(#{glob}) for types(#{types})")
          append_trigger(OpenHAB::DSL::Rules::Triggers::Watch::WATCH_TRIGGER_MODULE_ID,
                         conf,
                         attach: attach)
        end

        private

        #
        # Automatically creates globs for supplied paths if necessary
        # @param [Pathname] path to check
        # @param [String] specified glob
        #
        # @return [Pathname,String] Pathname to watch and glob to match
        def glob_for_path(path, glob)
          # Checks if the supplied pathname last element contains a glob char
          if OpenHAB::DSL::Rules::Triggers::Watch::GLOB_CHARS.any? { |char| path.basename.to_s.include? char }
            # Splits the supplied pathname into a glob string and parent path
            [path.basename.to_s, path.parent]
          elsif path.file? || !path.exist?
            # glob string matching end of Pathname and parent path
            ["*/#{path.basename}", path.parent]
          else
            [glob, path]
          end
        end
      end
    end
  end
end
# Add the watch handler to OpenHAB
OpenHAB::DSL::Rules::Triggers::Watch.add_watch_handler
