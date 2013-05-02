require 'rubygems'
require 'bundler'

Bundler.require
require 'sidekiq/testing'

MONGOID_HOST = ENV['MONGOID_SPEC_HOST'] || 'localhost'
MONGOID_PORT = ENV['MONGOID_SPEC_PORT'] || '27017'
DATABASE = 'async_callbacks_test'

Dir["./spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.color_enabled = true

  config.before(:each) do
    Mongoid.purge!
    Mongoid::IdentityMap.clear
  end
end

Mongoid.configure do |config|
  config.connect_to(DATABASE, :safe => true)
  ::BSON = ::Moped::BSON
  if ENV['LOGGER_LEVEL']
    Moped.logger = Logger.new(STDOUT).tap { |l| l.level = ENV['LOGGER_LEVEL'].to_i }
  end
end
