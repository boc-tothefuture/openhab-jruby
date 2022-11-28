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
          # Wraps the parent class's method to format non-Types.
          #
          # @!macro def_state_parsing_method
          #   @!method $1($2)
          #   @return [void]
          # @!visibility private
          def def_state_parsing_method(method, param_name)
            class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{method}(type)                                                             # def handle_command(type)
                type = link.item.format_#{(param_name == :state) ? :update : param_name}(type)  #   type = link.item.format_command(type)
                super(type)                                                                   #   super(type)
              end                                                                             # end
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
