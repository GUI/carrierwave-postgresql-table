require "carrierwave/orm/activerecord"

CarrierWave.configure do |config|
  config.storage = :postgresql_table
  if(CarrierWave::VERSION.to_f >= 1.0)
    config.cache_storage = :postgresql_table
  end
end
