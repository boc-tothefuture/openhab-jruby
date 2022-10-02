# frozen_string_literal: true

Bundler.require(:default, :test)

require 'rspec/openhab/configuration'
RSpec::OpenHAB::Configuration.use_root_instance = true

# clean any external OPENHAB or KARAF references; we want to use our private install
ENV.delete_if { |k| k.match?(/^(?:OPENHAB|KARAF)_/) }
ENV['OPENHAB_HOME'] = "#{Dir.pwd}/tmp/openhab"

require 'rspec-openhab-scripting'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random

  def fixture(filename)
    File.expand_path("../features/assets/#{filename}", __dir__)
  end

  config.before(:suite) do
    OpenHAB::Log.logger(OpenHAB::Configuration.log_prefix).level = :trace
  end

  Kernel.srand config.seed
end
