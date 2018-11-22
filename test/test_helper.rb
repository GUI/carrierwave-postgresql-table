# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "carrierwave-postgresql-table"

TEST_ROOT = File.expand_path(__dir__)
Dir[File.join(TEST_ROOT, "support/**/*.rb")].each { |f| require f }

require "minitest/autorun"
