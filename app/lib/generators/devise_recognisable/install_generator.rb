require 'rails/generators'
require 'rails/generators/migration'
require 'active_record'
require 'rails/generators/active_record'

module DeviseRecognisable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      # This method indicates the template that should be used by the generator. 
      def copy_migration
        migration_template './install_template.rb', 'db/migrate/create_recognisable_sessions.rb'
      end

      # Helper used in the template.
      def migration_parent
        Rails::VERSION::MAJOR == 4 ? 'ActiveRecord::Migration' : "ActiveRecord::Migration[#{ActiveRecord::Migration.current_version}]"
      end

      private

      # This required interface for Rails::Generators::Migration.
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