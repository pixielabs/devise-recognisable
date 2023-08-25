source "https://rubygems.org"

# Specify your gem's dependencies in devise-recognisable.gemspec
gemspec

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'sprockets-rails'
gem 'sqlite3'
gem 'rollbar', '~> 2.11', '>= 2.11.5'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'faker'
  gem 'factory_bot_rails'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'listen'
end
