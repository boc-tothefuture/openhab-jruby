# frozen_string_literal: true

require "time"

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.DateTimeItem

      # Adds methods to core OpenHAB DateTimeItem type to make it more natural
      # in Ruby
      class DateTimeItem < GenericItem
        # Time types need formatted as ISO8601
        # @!visibility private
        def format_type(command)
          return command.iso8601 if command.respond_to?(:iso8601)
          if command.is_a? java.time.ZonedDateTime
            return java.time.format.DateTimeFormatter::ISO_OFFSET_DATE_TIME.format(command)
          end

          super
        end
      end
    end
  end
end
