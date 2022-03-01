ENV["RAILS_ENV"] ||= 'test'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cancannible'
require 'active_record'
require 'sqlite3'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each {|f| require f}

RSpec.configure do |config|
  config.before do
    Cancannible.reset!
    run_migrations
  end
end
