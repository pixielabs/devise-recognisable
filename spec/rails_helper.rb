require 'rails/all'

require 'factory_bot'
require 'factory_bot_rails'
require 'rspec/rails'

require_relative 'dummy-app/config/environment'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

# set up db
# be sure to update the schema if required by doing
# - cd spec/support/rails_app
# - rake db:migrate
ActiveRecord::Schema.verbose = false
load 'dummy-app/db/schema.rb' # db agnostic

require 'spec_helper'
