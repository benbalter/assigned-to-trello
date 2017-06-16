require_relative 'lib/assigned_to_trello'
require 'dotenv'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task :cron do
  Dotenv.load

  Trello.configure do |config|
    config.developer_public_key = ENV['TRELLO_PUBLIC_KEY']
    config.member_token         = ENV['TRELLO_MEMBER_TOKEN']
  end

  AssignedToTrello.new.run
end

task :trello_token do
  Trello.open_public_key_url
  puts 'Please paste the developer API Key below:'
  key = STDIN.gets.chomp
  Trello.open_authorization_url key: key
end
