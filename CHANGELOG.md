# Change Log

## [1.0.1] - 2017-04-26

### Fixed
- Fix 404 handling in the Rack application. Thanks to [@bauersman](https://github.com/bauersman) for the fix.

## [1.0.0] - 2017-04-09

### Fixed
- Fix the Rack application when running with Rails under a relative URL root.
- Fix the Rack application to return 404 not found responses for unknown files.

### Changed
- Test against final, released version of CarrierWave 1.0.0.

## [0.1.3] - 2016-09-28

### Fixed
- Don't delete non-cached files when cleaning the cache.

## [0.1.2] - 2016-09-25

### Fixed
- Fix when connecting as a non-superuser account to PostgreSQL.

## [0.1.1] - 2016-09-25

### Fixed
- Fix `move_to` resulting in duplicate records.
- Fix `copy_to` leaving left over records in table.

## [0.1.0] - 2016-09-25

### Added
- Initial release.
