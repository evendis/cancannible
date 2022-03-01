require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module Cancannible
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      self.source_paths << File.join(File.dirname(__FILE__), 'templates')

      desc "This generator creates a cancannible initializer file and permissions model migration"

      def create_initializer_file
        template 'cancannible_initializer.rb', 'config/initializers/cancannible.rb'
      end

      def create_permission_migration_file
        migration_template 'migration.rb', 'db/migrate/create_cancannible_permissions.rb'
      end

      def create_permission_model_file
        template 'permission.rb', 'app/models/permission.rb'
      end

      # while methods have moved around this has been the implementation
      # since ActiveRecord 3.0
      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        if ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
        else
          "%.3d" % next_migration_number
        end
      end
    end
  end
end
