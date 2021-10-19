# frozen_string_literal: true

module OpenHAB
  module DSL
    module Rules
      # Module containing terse rule stubs
      module Terse
        %i[changed channel cron every updated received_command].each do |trigger|
          class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def #{trigger}(*args, name: nil, **kwargs, &block)                   # def changed(*args, name: nil, **kwargs, &block)
              # if no name is given, just default to the name of the rules file  #   # if no name is given, just default to the name of the rules file
              name ||= File.basename(caller_locations.last.path)                 #   name ||= File.basename(caller_locations.last.path)
              rule name do                                                       #   rule name do
                #{trigger}(*args, **kwargs)                                      #     changed(*args, **kwargs)
                run(&block)                                                      #     run(&block)
              end                                                                #   end
            end                                                                  # end
            module_function #{trigger.inspect}                                   # module_function :changed
          RUBY
        end
      end
    end
  end
end
