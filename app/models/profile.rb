class Profile < ApplicationRecord
  MAX_PHOTO_SIZE = 5.megabytes
  ALLOWED_PHOTO_TYPES = [ "image/png", "image/jpeg", "image/jpg", "image/webp" ].freeze

  belongs_to :user
  has_one_attached :photo

  validates :display_name, presence: true
  validate :photo_must_be_valid

  private

  def photo_must_be_valid
    return unless photo.attached?

    unless photo.blob.content_type.in?(ALLOWED_PHOTO_TYPES)
      errors.add(:photo, "must be PNG, JPG, or WEBP")
    end

    return unless photo.blob.byte_size > MAX_PHOTO_SIZE

    errors.add(:photo, "must be smaller than 5MB")
  end
end
