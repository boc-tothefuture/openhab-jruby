# frozen_string_literal: true

module YARD
  module Handlers
    module JRuby
      class JavaImportHandler < Ruby::Base
        include Base

        handles method_call(:java_import)

        process do
          statement.parameters(false).each do |klass|
            # first we auto-create the CodeObject for the class
            obj = infer_java_class(klass)
            next unless obj

            # don't overwrite an already-extant object with the same name
            next if ::YARD::Registry.at("#{namespace.path}::#{obj.simple_name}")

            # then we create a new constant in the current namespace
            register CodeObjects::ConstantObject.new(namespace, obj.simple_name) { |o|
                       o.source = statement
                       o.value = klass.source
                     }
          end
        end
      end
    end
  end
end
