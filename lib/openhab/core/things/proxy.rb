# frozen_string_literal: true

require "delegate"
require "forwardable"

module OpenHAB
  module Core
    module Things
      # Class is a proxy to underlying thing
      # @!visibility private
      class Proxy < Delegator
        extend Forwardable
        def_delegators :__getobj__, :class, :is_a?, :kind_of?, :instance_of?

        # Returns the list of channels associated with this Thing
        #
        # @note This is defined on this class, and not on {Thing}, because
        #   that's the interface and if you define it there, it will be hidden
        #   by the method on ThingImpl.
        #
        # @return [Array] channels
        def channels
          Thing::ChannelsArray.new(super.to_a)
        end

        #
        # Set the proxy item (called by super)
        #
        def __setobj__(thing)
          @uid = thing.uid
        end

        #
        # Lookup thing from thing registry
        #
        def __getobj__
          $things.get(@uid)
        end
      end
    end
  end
end
