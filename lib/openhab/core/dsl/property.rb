# frozen_string_literal: true

require 'core/log'

module DSLProperty
  include Logging

  def self.included(base)
    base.extend PropertyMethods
  end

  module PropertyMethods
    # Dynamically creates a property that acts and an accessor with no arguments
    # and a setter with any number of arguments or a block.
    def prop(name)
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

    # Dynamically creates a property array acts and an accessor with no arguments
    # and a pushes any number of arguments or a block onto they property array
    # You can provide a block to this method which can be used to check if the provided value is acceptable.
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

      if array_name
        define_method(array_name) do
          instance_variable_get("@#{array_name}")
        end
      end
    end
  end
end
