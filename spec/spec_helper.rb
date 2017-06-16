require_relative '../lib/assigned_to_trello'
require 'webmock/rspec'
WebMock.disable_net_connect!

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end

def fixture(fixture)
  File.read File.expand_path "fixtures/#{fixture}.json", File.dirname(__FILE__)
end

def stub_fixture(url, fixture)
  stub_request(:get, url) .to_return(
    status: 200,
    body: fixture(fixture),
    headers: { 'Content-Type' => 'application/json' }
  )
end
