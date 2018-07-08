require 'bundler/setup'
require 'webmock/rspec'
require 'base64'

ENV['RACK_ENV'] = 'test'
ENV['DB_URL'] = 'postgres:///courier_tweeter_test'
ENV['JWT_SECRET'] = Base64.encode64(Random.new.bytes(32))
ENV['SESSION_SECRET'] = 'super secret'

$LOAD_PATH.unshift File.expand_path(File.join(__FILE__, '..', '..'))
require 'config/environment'
require 'app'

WebMock.disable_net_connect!

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) do
      example.run
    end
  end
end

OmniAuth.config.test_mode = true
