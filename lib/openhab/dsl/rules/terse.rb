# frozen_string_literal: true

module OpenHAB
  module DSL
    module Rules
      # Module containing terse rule stubs
      module TerseRule
        %i[changed channel cron every updated received_command].each do |trigger|
          class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def #{trigger}(*args, name: nil, **kwargs, &block)                   # def changed(*args, name: nil, **kwargs, &block)
              name ||= infer_rule_name(#{trigger.inspect}, args, kwargs)         #   name ||= infer_rule_name(:changed, args, kwargs)
              name ||= infer_rule_name_from_block(block)                         #   name ||= infer_rule_name_from_block(block)
              rule name do                                                       #   rule name do
                #{trigger}(*args, **kwargs)                                      #     changed(*args, **kwargs)
                run(&block)                                                      #     run(&block)
              end                                                                #   end
            end                                                                  # end
            module_function #{trigger.inspect}                                   # module_function :changed
          RUBY
        end

        private

        # formulate a readable rule name such as "TestSwitch received command ON" if possible
        def infer_rule_name(trigger, args, kwargs) # rubocop:disable Metrics
          return unless %i[changed updated received_command].include?(trigger) &&
                        args.length == 1 &&
                        (kwargs.keys - %i[from to command]).empty?
          return if kwargs[:from].is_a?(Enumerable)
          return if kwargs[:to].is_a?(Enumerable)
          return if kwargs[:command].is_a?(Enumerable)

          trigger_name = trigger.to_s.tr('_', ' ')
          name = if args.first.is_a?(GroupItem::GroupMembers) # rubocop:disable Style/CaseLikeIf === doesn't work with GenericItem
                   "#{args.first.group.name}.members #{trigger_name}"
                 elsif args.first.is_a?(GenericItem)
                   "#{args.first.name} #{trigger_name}"
                 end
          return unless name

          name += " from #{kwargs[:from].inspect}" if kwargs[:from]
          name += " to #{kwargs[:to].inspect}" if kwargs[:to]
          name += " #{kwargs[:command].inspect}" if kwargs[:command]
          name
        end

        # get the block's source location, stripping some amount of common information
        def infer_rule_name_from_block(block)
          file = block.source_location.first.dup
          file.sub!("#{org.openhab.core.OpenHAB.config_folder}/", '')
          "#{file}:#{block.source_location.last}"
        end
      end
    end
  end
end
