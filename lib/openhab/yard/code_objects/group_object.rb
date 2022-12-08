# frozen_string_literal: true

module OpenHAB
  module YARD
    module CodeObjects
      class GroupObject < ::YARD::CodeObjects::Base
        attr_reader :full_name

        def initialize(namespace, name)
          @full_name = name
          name = name.delete(%(.?"')).tr(" ", "-")
          super
        end

        def path
          "group#{sep}#{super}"
        end

        alias_method :to_s, :full_name
      end
    end
  end
end
