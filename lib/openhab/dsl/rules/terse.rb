# frozen_string_literal: true

module OpenHAB
  module DSL
    module Rules
      # Module containing terse rule stubs
      module TerseRule
        %i[changed channel cron every updated received_command].each do |trigger|
          class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def #{trigger}(*args, name: nil, id: nil, **kwargs, &block)   # def changed(*args, name: nil, id: nil, **kwargs, &block)
              id ||= NameInference.infer_rule_id_from_block(block)        #   id ||= NameInference.infer_rule_id_from_block(block)
              script = block.source rescue nil                            #   script = block.source rescue nil
              rule name, id: id, script: script do                        #   rule name, id: id, script: script do
                #{trigger}(*args, **kwargs)                               #     changed(*args, **kwargs)
                run(&block)                                               #     run(&block)
              end                                                         #   end
            end                                                           # end
            module_function #{trigger.inspect}                            # module_function :changed
          RUBY
        end
      end
    end
  end
end
