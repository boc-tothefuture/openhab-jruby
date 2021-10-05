# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Events
        java_import Java::OrgOpenhabCoreItemsEvents::ItemCommandEvent

        #
        # Monkey patch with ruby style accesors
        #
        class ItemCommandEvent
          include Log

          alias command item_command

          #
          # For every value in the supplied enumeration create a corresponding method mapped to the lowercase
          # string representation of the enum value For example, an enum with values of STOP and START
          # would create methods stop? and start? that check if the command is corresponding STOP and START type
          #
          # @param [Java::JavaLang::Enum] command_enum Enumeration to create commands for
          #
          def self.def_enum_predicates(command_enum)
            command_enum.values.each do |command| # rubocop:disable Style/HashEachMethods : Java enum does not have each_value
              command_method = "#{command.to_s.downcase}?"
              logger.trace("Creating predicate method (#{command_method}) for #{self}")
              define_method(command_method) do
                self.command == command
              end
            end
          end
        end
      end
    end
  end
end
