# frozen_string_literal: true

require "test_helper"

class CarrierWave::PostgresqlTableTest < Minitest::Test
  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_version
    refute_nil ::CarrierWave::PostgresqlTable::VERSION
  end

  def test_blank_initial_uploader
    user = User.new
    assert(user.bio.blank?)
  end

  def test_blank_uploader_for_empty_string
    user = User.new(:bio => "")
    assert(user.bio.blank?)
  end

  def test_upload
    user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))
    assert_equal("Hello, World.\n\n", user.bio.read)

    assert_equal(1, User.count)
    assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
    assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
  end

  def test_upload_with_version
    animal = Animal.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))
    assert_equal("Hello, World.\n\n", animal.bio.read)
    assert_equal("Hello, World.", animal.bio.stripped.read)

    assert_equal(1, Animal.count)
    assert_equal(2, Animal.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
    assert_equal(2, Animal.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
  end

  def test_copy
    user1 = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))
    user2 = User.create(:bio => user1.bio.file)
    assert_equal("Hello, World.\n\n", user1.bio.read)
    assert_equal("Hello, World.\n\n", user2.bio.read)

    assert_equal(2, User.count)
    assert_equal(2, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
    assert_equal(2, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
  end

  def test_copy_with_version
    animal1 = Animal.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))
    animal2 = Animal.create(:bio => animal1.bio.file)
    assert_equal("Hello, World.\n\n", animal1.bio.read)
    assert_equal("Hello, World.\n\n", animal2.bio.read)

    assert_equal(2, Animal.count)
    assert_equal(4, Animal.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
    assert_equal(4, Animal.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
  end

  def test_file_size
    user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))
    assert_equal(15, user.bio.size)
  end

  def test_file_content_type
    user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))
    assert_equal("text/plain", user.bio.content_type)
  end

  def test_update
    user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))
    assert_equal("Hello, World.\n\n", user.bio.read)
    assert_equal(15, user.bio.size)

    assert_equal(1, User.count)
    assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
    assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)

    user = User.find(user.id)
    user.bio = File.new(File.join(TEST_ROOT, "fixtures/alternate/hello.txt"))
    user.save!
    assert_equal("Goodbye.\n", user.bio.read)
    assert_equal(9, user.bio.size)

    assert_equal(1, User.count)
    assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
    assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
  end

  def test_update_move_to
    cat = Cat.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))

    assert_equal("Hello, World.\n\n", cat.bio.read)
    assert_equal(15, cat.bio.size)

    assert_equal(1, Cat.count)
    assert_equal(1, Cat.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
    assert_equal(1, Cat.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)

    cat = Cat.find(cat.id)
    cat.bio = File.new(File.join(TEST_ROOT, "fixtures/alternate/hello.txt"))
    cat.save!
    assert_equal("Goodbye.\n", cat.bio.read)
    assert_equal(9, cat.bio.size)

    assert_equal(1, Cat.count)
    assert_equal(1, Cat.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
    assert_equal(1, Cat.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
  end

  if (CarrierWave::VERSION.to_f >= 1.0)
    def test_cache
      user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")), :legacy_code => "1nval1d!")
      assert(user.errors)
      assert_equal(0, User.count)
      assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
    end

    def test_cache_resave
      user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")), :legacy_code => "1nval1d!")
      refute(user.valid?)
      assert_equal(0, User.count)
      assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)

      user.legacy_code = "abc"
      assert(user.valid?)
      user.save!
      assert_equal(1, User.count)
      assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
    end

    def test_cache_resave_move_to
      cat = Cat.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")), :legacy_code => "1nval1d!")
      refute(cat.valid?)
      assert_equal(0, Cat.count)
      assert_equal(1, Cat.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(1, Cat.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)

      cat.legacy_code = "abc"
      assert(cat.valid?)
      cat.save!
      assert_equal(1, Cat.count)
      assert_equal(1, Cat.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(1, Cat.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
    end

    def test_clean_cache
      user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")), :legacy_code => "1nval1d!")
      assert(user.errors)
      assert_equal(0, User.count)
      assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)

      file = CarrierWave::Storage::PostgresqlTable::CarrierWaveFile.first
      file.update_column(:updated_at, Time.now.utc - 40)
      CarrierWave.clean_cached_files!(60)

      assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)

      file.update_column(:updated_at, Time.now.utc - 80)
      CarrierWave.clean_cached_files!(60)

      assert_equal(0, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(0, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
    end

    def test_clean_cache_does_not_delete_uncached_files
      User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))
      assert_equal(1, User.count)
      assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)

      file = CarrierWave::Storage::PostgresqlTable::CarrierWaveFile.first
      file.update_column(:updated_at, Time.now.utc - 40)
      CarrierWave.clean_cached_files!(60)

      assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)

      file.update_column(:updated_at, Time.now.utc - 80)
      CarrierWave.clean_cached_files!(60)

      assert_equal(1, User.connection.select_value("SELECT COUNT(*) FROM carrierwave_files").to_i)
      assert_equal(1, User.connection.select_value("SELECT COUNT(DISTINCT oid) FROM pg_largeobject_metadata").to_i)
    end
  end
end
