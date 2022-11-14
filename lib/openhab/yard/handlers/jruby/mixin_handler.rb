# frozen_string_literal: true

module YARD
  module Handlers
    module JRuby
      module MixinHandler
        include Base

        Ruby::MixinHandler.prepend(self)

        def process_mixin(mixin)
          if infer_java_class(mixin, CodeObjects::Java::InterfaceObject)
            # make the Ruby::MixinHandler accept that this is a ref
            def mixin.ref?
              true
            end
          end
          super
        end
      end
    end
  end
end
