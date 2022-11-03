# frozen_string_literal: true

RSpec.describe OpenHAB::Log do
  OpenHAB::Logger::LEVELS.each do |level|
    describe "##{level}?" do
      it "works" do
        expect { logger.send(:"#{level}?") }.not_to raise_error
      end
    end

    describe "##{level}" do
      it "works" do
        logger.send(level, "log line")
        expect(spec_log_lines).to include(match(/#{level.to_s.upcase}.* log line/))
      end

      it "accepts a block" do
        logger.send(level) { "Message in a Block" }
        expect(spec_log_lines).to include(match(/#{level.to_s.upcase}.* Message in a Block/))
      end
    end
  end

  describe "#name" do
    before do
      stub_const("MyClass", Class.new do
        class << self
          def logger_name
            logger.name
          end
        end

        def logger_name
          logger.name
        end
      end)
    end

    it "uses the file name at the top level" do
      expect(logger.name).to eql "org.openhab.automation.jrubyscripting.log_spec"
    end

    it "uses Object when it happens to be an object with nothing else" do
      expect(Object.new.logger.name).to eql "org.openhab.automation.jrubyscripting.Object"
    end

    it "includes the rule name inside a rule" do
      rule "log test", id: "log_test" do
        expect(logger.name).to eql "org.openhab.automation.jrubyscripting.log_test"
        on_start
        run do
          expect(logger.name).to eql "org.openhab.automation.jrubyscripting.log_test"
        end
      end
    end

    def local_method(file_logger_name)
      expect(logger.name).to eql file_logger_name
      expect(logger.name).not_to eql "org.openhab.automation.jrubyscripting.log_test"
    end

    it "uses the file's logger name for methods called by a rule" do
      file_logger_name = logger.name
      rule "log test" do
        on_start
        run { local_method(file_logger_name) }
      end
    end

    it "uses the rule name inside a timer block inside a rule" do
      executed = false
      rule "log test", id: "log_test" do
        on_start
        run do
          after(1.second) do
            executed = true
            expect(logger.name).to eql "org.openhab.automation.jrubyscripting.log_test" # rubocop:disable RSpec/ExpectInHook
          end
        end
      end
      Timecop.travel(5.seconds)
      execute_timers
      expect(executed).to be true
    end

    it "uses the file name inside a timer block" do
      file_logger_name = logger.name
      executed = false
      after(1.second) do
        executed = true
        expect(logger.name).to eql file_logger_name # rubocop:disable RSpec/ExpectInHook
      end

      Timecop.travel(5.seconds)
      execute_timers
      expect(executed).to be true
    end

    it "uses the class name inside a class method" do
      expect(MyClass.logger_name).to eql "org.openhab.automation.jrubyscripting.MyClass"
      expect(MyClass.new.logger_name).to eql "org.openhab.automation.jrubyscripting.MyClass"
    end

    it "uses the class name inside a class method inside a rule" do
      rule "my rule" do
        on_start
        run do
          expect(MyClass.logger_name).to eql "org.openhab.automation.jrubyscripting.MyClass"
          expect(MyClass.new.logger_name).to eql "org.openhab.automation.jrubyscripting.MyClass"
        end
      end
    end
  end
end
