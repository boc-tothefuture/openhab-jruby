# frozen_string_literal: true

require_relative 'type'

require_relative 'date_time_type'
require_relative 'decimal_type'
require_relative 'increase_decrease_type'
require_relative 'next_previous_type'
require_relative 'open_closed_type'
require_relative 'on_off_type'
require_relative 'percent_type'
require_relative 'play_pause_type'
require_relative 'quantity_type'
require_relative 'refresh_type'
require_relative 'rewind_fastforward_type'
require_relative 'stop_move_type'
require_relative 'string_type'
require_relative 'up_down_type'
require_relative 'un_def_type'

module OpenHAB
  module DSL
    #
    # Contains all OpenHAB *Type classes, as well as associated support
    # modules
    #
    module Types
      # Hash taking a Enum value, and returning two symbols of
      # predicates to be defined for it. the first is the "command" form,
      # which should be defined on ItemCommandEvent, and on the Type itself.
      # the second is "state" form, which should be defined on the applicable
      # Item, and on the Type itself.
      # @!visibility private
      PREDICATE_ALIASES = Hash.new { |_h, k| [:"#{k.downcase}?"] * 2 }
                              .merge({
                                       'PLAY' => %i[play? playing?],
                                       'PAUSE' => %i[pause? paused?],
                                       'REWIND' => %i[rewind? rewinding?],
                                       'FASTFORWARD' => %i[fast_forward? fast_forwarding?]
                                     }).freeze

      # Hash taking a Enum value, and returning an array of symbols
      # of the command to define for it
      # @!visibility private
      COMMAND_ALIASES = Hash.new { |_h, k| k.downcase.to_sym }
                            .merge({
                                     'FASTFORWARD' => :fast_forward
                                   }).freeze

      constants.map { |c| const_get(c) }
               .grep(Module)
               .select { |k| k < java.lang.Enum }
               .each do |klass|
        # make sure == from Type is inherited
        klass.remove_method(:==)

        # dynamically define predicate methods
        klass.values.each do |value| # rubocop:disable Style/HashEachMethods this isn't a Ruby hash
          # include all the aliases that we define for items both command and
          # state aliases (since types can be interrogated as an incoming
          # command, or as the state of an item)
          command = :"#{COMMAND_ALIASES[value.to_s]}?"
          states = PREDICATE_ALIASES[value.to_s]

          ([command] | states).each do |method|
            OpenHAB::Core.logger.trace("Defining #{klass}##{method} for #{value}")
            klass.class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{method}       # def on?
                self == #{value}  #   self == ON
              end                 # end
            RUBY
          end
        end
      end
    end
  end
end
