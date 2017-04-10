require "test_helper"
require "rack/test"

class RackAppTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def app
    CarrierWave::PostgresqlTable::RackApp.new
  end

  def test_returns_file
    user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))
    file = CarrierWave::Storage::PostgresqlTable::CarrierWaveFile.first

    get "/uploads/user/bio/#{user.id}/hello.txt"
    assert_equal(200, last_response.status)
    assert_equal(file.updated_at.httpdate, last_response.headers["Last-Modified"])
    assert_equal("text/plain", last_response.headers["Content-Type"])
    assert_equal("inline", last_response.headers["Content-Disposition"])
    assert_equal("Hello, World.\n\n", last_response.body)
  end

  def test_optional_download
    user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))

    get "/uploads/user/bio/#{user.id}/hello.txt?download=true"
    assert_equal(200, last_response.status)
    assert_equal("Hello, World.\n\n", last_response.body)
    assert_equal("attachment; filename=hello.txt", last_response.headers["Content-Disposition"])
  end

  def test_rails_relative_url_root
    Rails.application = TestRailsApp.new
    Rails.application.config.relative_url_root = "/foo/bar"
    user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))

    get "/foo/bar/uploads/user/bio/#{user.id}/hello.txt"
    assert_equal(200, last_response.status)
    assert_equal("Hello, World.\n\n", last_response.body)
  ensure
    Rails.application.config.relative_url_root = nil
    Rails.application = nil
  end

  def test_rails_relative_url_root_trailing_slash
    Rails.application = TestRailsApp.new
    Rails.application.config.relative_url_root = "/foo/bar/"
    user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))

    get "/foo/bar/uploads/user/bio/#{user.id}/hello.txt"
    assert_equal(200, last_response.status)
    assert_equal("Hello, World.\n\n", last_response.body)
  ensure
    Rails.application.config.relative_url_root = nil
    Rails.application = nil
  end

  def test_rails_relative_url_root_env
    ENV["RAILS_RELATIVE_URL_ROOT"] = "/foo/baz"
    Rails.application = TestRailsApp.new
    user = User.create(:bio => File.new(File.join(TEST_ROOT, "fixtures/hello.txt")))

    get "/foo/baz/uploads/user/bio/#{user.id}/hello.txt"
    assert_equal(200, last_response.status)
    assert_equal("Hello, World.\n\n", last_response.body)
  ensure
    ENV["RAILS_RELATIVE_URL_ROOT"] = nil
    Rails.application = nil
  end

  def test_not_found
    get "/uploads/foo/hello.txt"
    assert_equal(404, last_response.status)
    assert_equal("text/plain", last_response.headers["Content-Type"])
    assert_equal("Not Found", last_response.body)
  end
end
