# frozen_string_literal: true

require "singleton"

module OpenHAB
  module Core
    module Things
      #
      # Provides access to all OpenHAB {Thing things}, and acts like an array.
      #
      class Registry
        include LazyArray
        include Singleton

        #
        # Gets a specific {Thing}
        #
        # @param [String, ThingUID] uid Thing UID in the format `binding_id:type_id:thing_id`
        #   or via the ThingUID
        # @return [Thing, nil]
        #
        def [](uid)
          EntityLookup.lookup_thing(uid)
        end
        alias_method :include?, :[]
        alias_method :key?, :[]

        #
        # Explicit conversion to array
        #
        # @return [Array<Thing>]
        #
        def to_a
          $things.all.map { |thing| Proxy.new(thing) }
        end

        # Enter the Thing Builder DSL.
        # @yieldparam [DSL::Things::Builder] builder
        # @return [Object] The result of the block.
        def build(&block)
          DSL::Things::Builder.new.instance_eval(&block)
        end
      end
    end
  end
end
