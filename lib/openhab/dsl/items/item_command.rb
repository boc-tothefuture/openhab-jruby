# frozen_string_literal: true

require 'java'
require 'openhab/log/logger'

module OpenHAB
  module DSL
    module Items
      #
      # Holds methods to automatically generate commands and
      # accessors for items
      module ItemCommand
        include OpenHAB::Log

        #
        # For every value in the supplied enumeration create a corresponding method mapped to the lowercase
        # string representation of the enum value For example, an enum with values of STOP and START
        # would create methods stop() and start() that send the corresponding STOP and START commands to the item
        #
        # @param [Java::JavaLang::Enum] command_enum Enumeration to create commands for
        # @param [Hash] optional hash in which if a generated method name mactches a key, the value of that key
        #   will be used as the method name instead, for example `:play? => :playing?`
        #
        #
        def item_command(command_enum, methods = {})
          # rubocop:disable Style/HashEachMethods
          # Disable rule because Java enum does not support each_value
          command_enum.values.each do |command|
            command_method = command.to_s.downcase
            command_method = methods.transform_keys(&:to_sym).fetch(command_method.to_sym, command_method)
            logger.trace("Creating command method (#{command_method}) for #{self.class}")
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
        # @param [Hash] optional hash in which if a generated method name mactches a key, the value of that key
        #   will be used as the method name instead, for example `:play? => :playing?`
        #
        #
        def item_state(command_enum, methods = {})
          # rubocop:disable Style/HashEachMethods
          # Disable rule because Java enum does not support each_value
          command_enum.values.each do |command|
            status_method = "#{command.to_s.downcase}?"
            status_method = methods.transform_keys(&:to_sym).fetch(status_method.to_sym, status_method)
            logger.trace("Creating status method (#{status_method}) for #{self.class}")
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
        # @param [Hash] optional hash in which if a generated method name mactches a key, the value of that key
        #   will be used as the method name instead, for example `:play? => :playing?`
        #
        def item_type(item_class, methods = {})
          item_class.field_reader(:ACCEPTED_DATA_TYPES)
          item_class.field_reader(:ACCEPTED_COMMAND_TYPES)
          item_class.ACCEPTED_DATA_TYPES.select(&:is_enum)
                    .grep_v(UnDefType)
                    .each { |type| item_state(type.ruby_class, methods) }
          item_class.ACCEPTED_COMMAND_TYPES.select(&:is_enum)
                    .grep_v(UnDefType)
                    .each { |type| item_command(type.ruby_class, methods) }
        end
      end
    end
  end
end
