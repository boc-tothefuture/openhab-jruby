# frozen_string_literal: true

module OpenHAB
  module YARD
    module CLI
      module Stats
        ::YARD::CLI::Stats.prepend(self)

        def stats_for_constants
          objs = all_objects.select { |m| m.type == :constant }
          undoc = objs.find_all do |m|
            # allow constants that are simple aliases
            # to not have additional documentation
            m.docstring.blank? && m.target.nil?
          end
          @undoc_list |= undoc if @undoc_list

          output "Constants", objs.size, undoc.size
        end
      end
    end
  end
end
