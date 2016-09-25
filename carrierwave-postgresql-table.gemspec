# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "carrierwave/postgresql_table/version"

Gem::Specification.new do |spec|
  spec.name          = "carrierwave-postgresql-table"
  spec.version       = CarrierWave::PostgresqlTable::VERSION
  spec.authors       = ["Nick Muerdter"]
  spec.email         = ["nick.muerdter@nrel.gov"]

  spec.summary       = %q{Store CarrierWave files in PostgreSQL (supporting multiple versions per uploader).}
  spec.homepage      = "https://github.com/GUI/carrierwave-postgresql-table"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_dependency "carrierwave"
  spec.add_dependency "pg"

  spec.add_development_dependency "appraisal", "~> 2.1.0"
  spec.add_development_dependency "database_cleaner", "~> 1.5.3"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
