require "rails/generators/active_record"

module CarrierwavePostgresqlTable
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root(File.expand_path("../templates", __FILE__))

    def self.next_migration_number(dirname)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    def create_migration_file
      migration_template("migration.rb.erb", "db/migrate/create_carrierwave_files.rb")
    end
  end
end
