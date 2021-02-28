# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module Items
      #
      # Holds methods to automatically generate commands and
      # accessors for items
      module ItemCommand
        #
        # For every value in the supplied enumeration create a corresponding method mapped to the lowercase
        # string representation of the enum value For example, an enum with values of STOP and START
        # would create methods stop() and start() that send the corresponding STOP and START commands to the item
        #
        # @param [Java::JavaLang::Enum] command_enum Enumeration to create commands for
        #
        #
        def item_command(command_enum)
          # rubocop:disable Style/HashEachMethods
          # Disable rule because Java enum does not support each_value
          command_enum.values.each do |command|
            command_method = command.to_s.downcase
            define_method(command_method) do
              self.command(command)
            end
          end
          # rubocop:enable Style/HashEachMethods
        end

        #
        # For every value in the supplied enumeration create a corresponding method mapped to the lowercase
        # string representation appended with a question mark '?' of the enum value For example,
        # an enum with values of UP and DOWN would create methods up? and down? that check
        # if the current state matches the value of the enum
        #
        # @param [Java::JavaLang::Enum] command_enum Enumeration to create methods for each value
        #   to check if current state matches that enum
        # @yield [state] Optional block that can be used to transform state prior to comparison
        #
        #
        def item_state(command_enum)
          # rubocop:disable Style/HashEachMethods
          # Disable rule because Java enum does not support each_value
          command_enum.values.each do |command|
            status_method = "#{command.to_s.downcase}?"
            define_method(status_method) do
              state? && state.as(command_enum) == command
            end
          end
          # rubocop:enable Style/HashEachMethods
        end

        #
        # Extract the accepted state and command types from the specified OpenHAB
        # Item class and pass them to item_state/item_command
        #
        # @param [Java::JavaLang::Class] item_class a Class that implements Java::OrgOpenhabCoreItems::Item
        #
        def item_type(item_class)
          item_class.field_reader(:ACCEPTED_DATA_TYPES)
          item_class.field_reader(:ACCEPTED_COMMAND_TYPES)
          item_class.ACCEPTED_DATA_TYPES.select(&:is_enum).grep_v(UnDefType).each { |type| item_state(type.ruby_class) }
          item_class.ACCEPTED_COMMAND_TYPES.select(&:is_enum).grep_v(UnDefType).each do |type|
            item_command(type.ruby_class)
          end
        end
      end
    end
  end
end
