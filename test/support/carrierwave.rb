# frozen_string_literal: true

require "carrierwave/orm/activerecord"

CarrierWave.configure do |config|
  config.storage = :postgresql_table
  if (CarrierWave::VERSION.to_f >= 1.0)
    config.cache_storage = :postgresql_table
  else
    config.cache_dir = File.expand_path("../tmp/cache", __dir__)
  end
end
