# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "carrierwave/postgresql_table/version"

Gem::Specification.new do |spec|
  spec.name          = "carrierwave-postgresql-table"
  spec.version       = CarrierWave::PostgresqlTable::VERSION
  spec.authors       = ["Nick Muerdter"]
  spec.email         = ["nick.muerdter@nrel.gov"]

  spec.summary       = "Store CarrierWave files in PostgreSQL (supporting multiple versions per uploader)."
  spec.homepage      = "https://github.com/GUI/carrierwave-postgresql-table"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.2.0"

  spec.add_dependency "activerecord"
  spec.add_dependency "carrierwave"
  spec.add_dependency "pg"

  spec.add_development_dependency "appraisal", "~> 2.2.0"
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "database_cleaner", "~> 1.7.0"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "rack-test", ">= 0.6"
  spec.add_development_dependency "rails", ">= 4.2"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rubocop", ">= 0.60"
end
