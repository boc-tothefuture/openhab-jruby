# frozen_string_literal: true

require 'openhab/dsl/monkey_patch/events/item_command'
require 'openhab/dsl/types/types'

require_relative 'item_registry'

require_relative 'generic_item'
require_relative 'switch_item'
require_relative 'date_time_item'
require_relative 'dimmer_item'
require_relative 'color_item'
require_relative 'contact_item'
require_relative 'group_item'
require_relative 'image_item'
require_relative 'location_item'
require_relative 'number_item'
require_relative 'player_item'
require_relative 'rollershutter_item'
require_relative 'string_item'

require_relative 'ensure'
require_relative 'timed_command'

module OpenHAB
  module DSL
    # Contains all OpenHAB *Item classes, as well as associated support
    # modules
    module Items
      include OpenHAB::Log

      class << self
        private

        # takes an array of Type java classes and returns
        # all the Enum values, in a flat array
        def values_for_enums(enums)
          enums.map(&:ruby_class)
               .select { |k| k < java.lang.Enum }
               .flat_map(&:values)
        end

        # define predicates for checking if an item is in one of the Enum states
        def def_predicate_methods(klass)
          values_for_enums(klass.ACCEPTED_DATA_TYPES).each do |state|
            _command_predicate, state_predicate = OpenHAB::DSL::PREDICATE_ALIASES[state.to_s]
            next if klass.instance_methods.include?(state_predicate)

            logger.trace("Defining #{klass}##{state_predicate} for #{state}")
            klass.class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{state_predicate}   # def on?
                raw_state == #{state}  #   raw_state == ON
              end                      # end
            RUBY
          end
        end

        # defined methods for commanding an item to one of the Enum states
        # as well as predicates for if an ItemCommandEvent is one of those commands
        def def_command_methods(klass) # rubocop:disable Metrics method has single purpose
          values_for_enums(klass.ACCEPTED_COMMAND_TYPES).each do |value|
            command = OpenHAB::DSL::COMMAND_ALIASES[value.to_s]
            next if klass.instance_methods.include?(command)

            logger.trace("Defining #{klass}##{command} for #{value}")
            klass.class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{command}(for: nil, on_expire: nil, &block)                                          # def on(for: nil, on_expire: nil, &block )
                command(#{value}, for: binding.local_variable_get(:for), on_expire: on_expire, &block)  #   command(ON, for: nil, expire: nil, &block)
              end                                                                                       # end
            RUBY

            logger.trace("Defining Enumerable##{command} for #{value}")
            Enumerable.class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{command}        # def on
                each(&:#{command})  #   each(&:on)
              end                   # end
            RUBY

            # Override the inherited methods from Enumerable and send it to the base_item
            GroupItem.class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{command}                 # def on
                method_missing(:#{command})  #   method_missing(:on)
              end                            # end
            RUBY

            logger.trace("Defining ItemCommandEvent##{command}? for #{value}")
            MonkeyPatch::Events::ItemCommandEvent.class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{command}?        # def refresh?
                command == #{value}  #   command == REFRESH
              end                    # end
            RUBY
          end
        end
      end

      # sort classes by hierarchy so we define methods on parent classes first
      constants.map { |c| const_get(c) }
               .grep(Module)
               .select { |k| k <= GenericItem && k != GroupItem && k != StringItem }
               .sort { |a, b| a < b ? 1 : -1 }
               .each do |klass|
        klass.field_reader :ACCEPTED_COMMAND_TYPES, :ACCEPTED_DATA_TYPES unless klass == GenericItem

        def_predicate_methods(klass)
        def_command_methods(klass)
      end
    end
  end
end
