module CarrierWave
  module Storage
    class PostgresqlTable < Abstract
      def store!(file)
        if(uploader.move_to_store && file.kind_of?(CarrierWave::Storage::PostgresqlTable::File))
          file.move_to(uploader.store_path)
          file
        else
          f = CarrierWave::Storage::PostgresqlTable::File.new(uploader.store_path)
          f.store(file)
          f
        end
      end

      def retrieve!(identifier)
        CarrierWave::Storage::PostgresqlTable::File.new(uploader.store_path(identifier))
      end

      def cache!(new_file)
        f = CarrierWave::Storage::PostgresqlTable::File.new(uploader.cache_path)
        f.store(new_file)
        f
      end

      def retrieve_from_cache!(identifier)
        CarrierWave::Storage::PostgresqlTable::File.new(uploader.cache_path(identifier))
      end

      def delete_dir!(path)
        # This is only supposed to delete *empty* directories, which don't
        # exist in our database.
      end

      def clean_cache!(seconds)
        time = Time.now - seconds.seconds
        CarrierWaveFile.delete_all_files("path LIKE #{CarrierWaveFile.sanitize(::File.join(uploader.cache_dir, "%"))} AND updated_at < #{CarrierWaveFile.sanitize(time)}")
      end

      class CarrierWaveFile < ::ActiveRecord::Base
        self.table_name = "carrierwave_files"

        def self.delete_all_files(conditions)
          self.transaction do
            self.connection.execute("SELECT lo_unlink(pg_largeobject_oid) FROM (SELECT DISTINCT pg_largeobject_oid FROM #{self.table_name} WHERE #{conditions}) AS oids")
            self.where(conditions).delete_all
          end
        end
      end

      class File
        READ_CHUNK_SIZE = 16384
        STREAM_CHUNK_SIZE = 16384

        attr_reader :path

        def initialize(path)
          @path = path
          @record = CarrierWaveFile.find_or_initialize_by(:path => path)
          @read_pos = 0
        end

        def read(length = nil, buffer = nil)
          data = nil
          CarrierWaveFile.transaction do
            raw_connection = CarrierWaveFile.connection.raw_connection

            begin
              lo = raw_connection.lo_open(@record.pg_largeobject_oid)
              if(length)
                raw_connection.lo_lseek(lo, @read_pos, PG::SEEK_SET)
                data = raw_connection.lo_read(lo, length)
                @read_pos = raw_connection.lo_tell(lo)
              else
                data = raw_connection.lo_read(lo, self.size)
              end
            ensure
              raw_connection.lo_close(lo) if(lo)
            end
          end

          if(buffer && data)
            buffer.replace(data)
          end

          data
        end

        def to_tempfile
          Tempfile.new(:binmode => true).tap do |tempfile|
            IO.copy_stream(self, tempfile)
            self.rewind
            tempfile.rewind
            tempfile.fsync
          end
        end

        def filename
          ::File.basename(@path)
        end

        def last_modified
          @record.updated_at
        end

        def size
          @size = @record.size || fetch_size
        end

        def eof?
          @read_pos == self.size
        end

        def rewind
          @read_pos = 0
        end

        def content_type
          @record.content_type
        end

        def content_type=(new_content_type)
          @record.update_attribute(:content_type, new_content_type)
        end

        def url(options = {})
          ::File.join("/", @path)
        end

        def store(new_file)
          CarrierWaveFile.transaction do
            connection = CarrierWaveFile.connection
            raw_connection = connection.raw_connection
            oid = nil
            if(new_file.kind_of?(CarrierWave::Storage::PostgresqlTable::File))
              file = new_file
            else
              file = new_file.to_file
            end

            begin
              oid = @record.pg_largeobject_oid || raw_connection.lo_creat
              handle = raw_connection.lo_open(oid, PG::INV_WRITE)
              raw_connection.lo_truncate(handle, 0)
              buffer = ""
              until file.eof?
                file.read(READ_CHUNK_SIZE, buffer)
                raw_connection.lo_write(handle, buffer)
              end
              file.rewind
            ensure
              raw_connection.lo_close(handle)
            end

            begin
              old_oid = @record.pg_largeobject_oid
              @record.pg_largeobject_oid = oid
              @record.size = new_file.size
              @record.content_type = new_file.content_type
              @record.save

              # Cleanup old, unused largeobject OIDs if we're updating the
              # record with a new OID reference.
              if(old_oid && old_oid != oid)
                old_references = connection.select_value("SELECT COUNT(*) FROM #{CarrierWaveFile.table_name} WHERE pg_largeobject_oid = #{CarrierWaveFile.sanitize(old_oid)}").to_i
                if(old_references == 0)
                  raw_connection.lo_unlink(old_oid)
                end
              end
            rescue ::ActiveRecord::RecordNotUnique
              @record = CarrierWaveFile.find_or_initialize_by(:path => @path)
              retry
            end
          end
        end

        def exists?
          @record && @record.persisted?
        end

        def move_to(new_path)
          CarrierWaveFile.transaction do
            # Remove any existing files at the current path.
            CarrierWaveFile.delete_all_files("path = #{CarrierWaveFile.sanitize(new_path)} AND id != #{CarrierWaveFile.sanitize(@record.id)}")

            # Change the current record's path to the new path.
            @record.update_attribute(:path, new_path)
          end
        end

        def delete
          CarrierWaveFile.delete_all_files("id = #{CarrierWaveFile.sanitize(@record.id)}")
        end

        private

        def fetch_size
          size = nil
          CarrierWaveFile.transaction do
            raw_connection = CarrierWaveFile.connection.raw_connection
            lo = raw_connection.lo_open(@record.pg_largeobject_oid)
            size = raw_connection.lo_lseek(lo, 0, PG::SEEK_END)
          end

          size
        end
      end
    end
  end
end
