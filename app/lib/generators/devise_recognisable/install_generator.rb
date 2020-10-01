require 'rails/generators'
require 'rails/generators/migration'
require 'active_record'
require 'rails/generators/active_record'

module DeviseRecognisable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.dirname(__FILE__)

      # This method indicates the template that should be used by the generator. 
      def copy_migration
        migration_template './install_template.rb', 'db/migrate/create_recognisable_sessions.rb'
      end

      def ip_column
        # Padded with spaces so it aligns nicely with the rest of the columns.
        "%-8s" % (postgresql? ? "inet" : "string")
      end

      def postgresql?
        config = ActiveRecord::Base.configurations[Rails.env]
        config && config['adapter'] == 'postgresql'
      end

      private

      # This is a required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        if ::ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
        else
          "%.3d" % next_migration_number
        end
      end
    end
  end
end