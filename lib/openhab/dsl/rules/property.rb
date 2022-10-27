# frozen_string_literal: true

require "openhab/log/logger"

module OpenHAB
  module DSL
    module Rules
      #
      # Provides methods to support DSL properties
      #
      module Property
        include OpenHAB::Log

        # @!visibility private
        #
        # Extend the calling object with the property methods
        #
        # @param [Object] base object to extend
        #
        #
        def self.included(base)
          base.extend PropertyMethods
        end

        #
        # Methods that support creating properties in the DSL
        #
        module PropertyMethods
          #
          # Dynamically creates a property that acts and an accessor with no arguments
          # and a setter with any number of arguments or a block.
          #
          # @param [String] name of the property
          #
          #
          def prop(name)
            # rubocop rules are disabled because this method is dynamically defined on the calling
            #   object making calls to other methods in this module impossible, or if done on methods
            #   in this module than instance variable belong to the module not the calling class
            define_method(name) do |*args, &block|
              if args.length.zero? && block.nil? == true
                instance_variable_get("@#{name}")
              else
                logger.trace("Property '#{name}' called with args(#{args}) and block(#{block})")
                if args.length == 1
                  instance_variable_set("@#{name}", args.first)
                elsif args.length > 1
                  instance_variable_set("@#{name}", args)
                elsif block
                  instance_variable_set("@#{name}", block)
                end
              end
            end
          end

          #
          # Dynamically creates a property array acts and an accessor with no arguments
          # and a pushes any number of arguments or a block onto they property array
          # You can provide a block to this method which can be used to check if the provided value is acceptable.
          #
          # @param [String] name of the property
          # @param [String] array_name name of the array to use, defaults to name of property
          # @param [Class] wrapper object to put around elements added to the array
          #
          def prop_array(name, array_name: nil, wrapper: nil)
            define_method(name) do |*args, &block|
              array_name ||= name
              if args.length.zero? && block.nil? == true
                instance_variable_get("@#{array_name}")
              else
                logger.trace("Property '#{name}' called with args(#{args}) and block(#{block})")
                if args.length == 1
                  insert = args.first
                elsif args.length > 1
                  insert = args
                elsif block
                  insert = block
                end
                yield insert if block_given?
                insert = wrapper.new(insert) if wrapper
                instance_variable_set("@#{array_name}", (instance_variable_get("@#{array_name}") || []) << insert)
              end
            end

            return unless array_name

            define_method(array_name) do
              instance_variable_get("@#{array_name}")
            end
          end
        end
      end
    end
  end
end
