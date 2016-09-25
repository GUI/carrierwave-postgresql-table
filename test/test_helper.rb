$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "carrierwave-postgresql-table"

TEST_ROOT = File.expand_path("../", __FILE__)
Dir[File.join(TEST_ROOT, "support/**/*.rb")].each { |f| require f }

require "minitest/autorun"
