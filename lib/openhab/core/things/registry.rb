# frozen_string_literal: true

require "singleton"

module OpenHAB
  module Core
    module Things
      #
      # Wraps all Things in a delegator to underlying set and provides lookup method
      #
      class Registry
        include LazyArray
        include Singleton

        #
        # Gets a specific thing
        #
        # @param [String, ThingUID] Thing UID in the format `binding_id:type_id:thing_id`
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
          $things.getAll.map { |thing| Thing.new(thing) }
        end

        # Enter the Thing Builder DSL.
        # @yield [DSL::Things::Builder] Builder object.
        # @return [Object] The result of the block.
        def build(&block)
          DSL::Things::Builder.new.instance_eval(&block)
        end
      end
    end
  end
end
