# frozen_string_literal: true

require "active_record"
require "pg"
require "carrierwave"
require "carrierwave/storage/postgresql_table"
require "carrierwave/postgresql_table/rack_app"

CarrierWave::Uploader::Base.storage_engines[:postgresql_table] = "CarrierWave::Storage::PostgresqlTable"
