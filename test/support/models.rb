class UserBioUploader < CarrierWave::Uploader::Base
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end

class AnimalBioUploader < CarrierWave::Uploader::Base
  version :stripped do
    process :strip_text
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  private

  def strip_text
    cache_stored_file! if !cached?
    data = File.read(current_path).strip
    File.open(current_path, "wb") { |f| f.write(data) }
  end
end

class User < ActiveRecord::Base
  mount_uploader :bio, UserBioUploader

  validates :legacy_code, :allow_nil => true, :format => {
    :with => /\A[a-zA-Z]+\z/,
    :message => "only allows letters",
  }
end

class Animal < ActiveRecord::Base
  mount_uploader :bio, AnimalBioUploader
end
