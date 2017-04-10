# carrierwave-postgresql-table

[![Circle CI](https://circleci.com/gh/GUI/carrierwave-postgresql-table.svg?style=svg)](https://circleci.com/gh/GUI/carrierwave-postgresql-table)

A PostgreSQL storage adapter for [CarrierWave](https://github.com/carrierwaveuploader/carrierwave). Files are stored as PostgreSQL [large objects](https://www.postgresql.org/docs/current/static/largeobjects.html).

This gem is similar to [carrierwave-postgresql](https://github.com/diogob/carrierwave-postgresql), but differs in how it stores file metadata. This gem uses an extra table to store additional file metadata, allowing it to support multiple CarrierWave [versions](https://github.com/carrierwaveuploader/carrierwave#adding-versions) on a single uploader.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "carrierwave-postgresql-table"
```

## Compatibility

carrierwave-postgresql-table is tested against the following versions of CarrierWave and Rails:

- CarrierWave 0.11
- CarrierWave 1.0
- Rails 4.2
- Rails 5.0

## Usage

Generate the table to store the file uploads:

```sh
$ rails generate carrierwave_postgresql_table:migration
$ rake db:migrate
```

Adjust your uploader to use the `postgresql_table` storage adapter:

```ruby
class AvatarUploader < CarrierWave::Uploader::Base
  storage :postgresql_table

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
```

An optional Rack application is available to provide an endpoint that will stream your files from PostgreSQL. To enable this endpoint, you can mount it in your `config/routes.rb` file:

```ruby
Rails.application.routes.draw do
  mount CarrierWave::PostgresqlTable::RackApp.new => "/uploads"
end
```

The Rack application can also be combined with other routing functionality. For example, to limit uploads to authenticated users when used with Devise:

```ruby
Rails.application.routes.draw do
  authenticate :user do
    mount CarrierWave::PostgresqlTable::RackApp.new => "/uploads"
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/GUI/carrierwave-postgresql-table](https://github.com/GUI/carrierwave-postgresql-table).

## Acknowledgments

Hat tip to the people behind [carrierwave-postgresql](https://github.com/diogob/carrierwave-postgresql) and [refile-postgres](https://github.com/krists/refile-postgres), which this code is based on.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
