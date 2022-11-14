# frozen_string_literal: true

module OpenHAB
  module Core
    module Things
      #
      # Contains methods for {OpenHAB::DSL.profile profile}'s callback to forward commands between items
      # and channels.
      #
      module ProfileCallback
        class << self
          #
          # Wraps the parent class's method to parse non-Types.
          #
          # @!macro def_state_parsing_method
          #   @!method $1($2)
          #   @return [void]
          # @!visibility private
          def def_state_parsing_method(method, param_name)
            class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{method}(state)                                                                                # def handle_command(state)
                  state = link.item.format_type(state)                                                            #   state = link.item.format_type(state)
                  if state.is_a?(String)                                                                          #   if state.is_a?(String)
                    types = link.item.#{param_name == :command ? :accepted_command_types : :accepted_data_types}  #     types = link.item.accepted_command_types
                    state = org.openhab.core.types.TypeParser.parse_state(types.map(&:java_class), state)         #     state = org.openhab.core.types.TypeParser.parse_state(types.map(&:java_class), state)
                  end                                                                                             #   end
                  super(state)                                                                                    #   super(state)
              end                                                                                                 # end
            RUBY
          end
        end

        #
        # Forward the given command to the respective thing handler.
        #
        # @param [Command] command
        #
        def_state_parsing_method(:handle_command, :command)

        #
        # Send a command to the framework.
        #
        # @param [Command] command
        #
        def_state_parsing_method(:send_command, :command)

        #
        # Send a state update to the framework.
        #
        # @param [State] state
        #
        def_state_parsing_method(:send_update, :state)
      end
    end
  end
end
