Feature:  java_entities
  Java entities are not pushed into ruby context

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Java entities inside rules
    Given items:
      | type   | name    |
      | Switch | Switch1 |
    And a deployed rule
      """
      def ruby_types
        OpenHAB::DSL::Types.constants(false).select { |const| const.to_s.end_with?('Type') }
          .select {|const| OpenHAB::DSL::Types.const_get(const).instance_of?(Class) }
      end

      rule 'test' do
        received_command Switch1
        run do |event|
          logger.debug("Obj: #{ruby_types}")
          any_java = ruby_types.map { |type| Object.const_get(type) }
            .select { |klass| klass.class.name.start_with? 'Java' }
            .tap { |obj| logger.debug("Java types found: #{obj}") }
            .any?

          logger.info("Any java types? #{any_java}") if event.command == OFF
          logger.error PercentType.new(10)
          logger.error HSBType.new(1,2,3)
          logger.info("No errors")
        end
      end
      Switch1 << ON
      sleep 1
      Switch1 << OFF
      """
    Then It should log "No errors" within 5 seconds
  # Then It should log "Any java types? false" within 5 seconds

  Scenario: Java entities on the top level
    Given a deployed rule
      """
      def ruby_types
        OpenHAB::DSL::Types.constants(false).select { |const| const.to_s.end_with?('Type') }
          .select {|const| OpenHAB::DSL::Types.const_get(const).instance_of?(Class) }
      end


      logger.debug("Obj: #{ruby_types}")
      any_java = ruby_types.map { |type| Object.const_get(type) }
        .select { |klass| klass.class.name.start_with? 'Java' }
        .tap { |obj| logger.debug("Java types found: #{obj}") }
        .any?
      logger.info("Any java types? #{any_java}")

      logger.error PercentType.new(10)
      logger.error HSBType.new(1,2,3)
      logger.info("No errors")
      """
    Then It should log "No errors" within 5 seconds
