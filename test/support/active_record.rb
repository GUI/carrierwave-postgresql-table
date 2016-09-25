ActiveRecord::Base.establish_connection({
  :adapter => "postgresql",
  :database => "carrierwave_postgresql_table_test",
  :username => "postgres",
  :host => "localhost",
})

if ActiveRecord::VERSION::MAJOR == 4
  # Prevent deprecation warnings.
  ActiveRecord::Base.raise_in_transactional_callbacks = true
end

ActiveRecord::Base.connection.create_table :carrierwave_files, :force => true do |t|
  t.column :path, :string, :null => false
  t.column :pg_largeobject_oid, :oid, :null => false
  t.column :size, :integer, :null => false
  t.column :content_type, :string
  t.timestamps(:null => false)
end
ActiveRecord::Base.connection.add_index :carrierwave_files, :path, :unique => true

ActiveRecord::Base.connection.create_table :users, :force => true do |t|
  t.column :bio, :string
  t.column :legacy_code, :string
  t.timestamps(:null => false)
end

ActiveRecord::Base.connection.create_table :animals, :force => true do |t|
  t.column :bio, :string
  t.timestamps(:null => false)
end

require "database_cleaner"

DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with(:truncation)

# Delete all the pg_largeobjects in addition to truncating the normal tables.
ActiveRecord::Base.connection.execute("SELECT lo_unlink(loid) FROM (SELECT DISTINCT loid FROM pg_largeobject) AS oids")
