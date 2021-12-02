# frozen_string_literal: true

require_relative 'generic_item'

module OpenHAB
  module DSL
    # Functionality to implement +ensure+/+ensure_states+
    module Ensure
      # Contains the global +ensure_states+ method
      module EnsureStates
        # Global method that takes a block and for the duration of the block
        # all commands sent will check if the item is in the command's state
        # before sending the command.
        #
        # @example Turn on several switches only if they're not already on
        #   ensure_states do
        #     Switch1.on
        #     Switch2.on
        #   end
        def ensure_states
          old = Thread.current[:ensure_states]
          Thread.current[:ensure_states] = true
          yield
        ensure
          Thread.current[:ensure_states] = old
        end
        module_function :ensure_states
      end

      # Contains the +ensure+ method mixed into {GenericItem} and {GroupItem::GroupMembers}
      module Ensurable
        # Fluent method call that you can chain commands on to, that will
        # then automatically ensure that the item is not in the command's
        # state before sending the command.
        #
        # @example Turn switch on only if it's not on
        #   MySwitch.ensure.on
        # @example Turn on all switches in a group that aren't already on
        #   MySwitchGroup.members.ensure.on
        def ensure
          GenericItemDelegate.new(self)
        end
      end

      # Extensions for {Items::GenericItem} to implement {Ensure}'s
      # functionality
      module GenericItem
        include Ensurable

        # If +ensure_states+ is active (by block or chained method), then
        # check if this item is in the command's state before actually
        # sending the command
        %i[command update].each do |ensured_method|
          define_method(ensured_method) do |command|
            return super(command) unless Thread.current[:ensure_states]

            logger.trace do
              "#{name} ensure #{command}, format_type_pre: #{format_type_pre(command)}, current state: #{state}"
            end
            return if state == format_type_pre(command)

            super(command)
          end
        end
        alias << command
      end

      # "anonymous" class that wraps any method call in +ensure_states+
      # before forwarding to the wrapped object
      # @!visibility private
      class GenericItemDelegate
        def initialize(item)
          @item = item
        end

        # @!visibility private
        # this is explicitly defined, instead of aliased, because #command
        # doesn't actually exist as a method, and will go through method_missing
        def <<(command)
          command(command)
        end

        # activate +ensure_states+ before forwarding to the wrapped object
        def method_missing(method, *args, &block)
          return super unless @item.respond_to?(method)

          ensure_states do
            @item.__send__(method, *args, &block)
          end
        end

        # .
        def respond_to_missing?(method, include_private = false)
          @item.respond_to?(method, include_private) || super
        end
      end
    end

    module Items
      GenericItem.prepend(OpenHAB::DSL::Ensure::GenericItem)
      GroupItem::GroupMembers.include(OpenHAB::DSL::Ensure::Ensurable)
    end
  end
end

Object.include OpenHAB::DSL::Ensure::EnsureStates
