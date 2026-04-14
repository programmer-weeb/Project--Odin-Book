class Profile < ApplicationRecord
  belongs_to :user

  validates :display_name, presence: true
end

