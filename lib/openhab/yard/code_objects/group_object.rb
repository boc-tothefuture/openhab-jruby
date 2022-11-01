# frozen_string_literal: true

module OpenHAB
  module YARD
    module CodeObjects
      class GroupObject < ::YARD::CodeObjects::Base
        def path
          "group#{sep}#{super}"
        end

        def to_s
          name
        end
      end
    end
  end
end
