class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :sent_follow_requests, class_name: "UserFollowRequest", foreign_key: "requesting_user_id", dependent: :destroy
  has_many :received_follow_requests, class_name: "UserFollowRequest", foreign_key: "requested_user_id", dependent: :destroy

  has_many :accepted_sent_requests, -> { accepted }, class_name: "UserFollowRequest", foreign_key: "requesting_user_id"
  has_many :accepted_received_requests, -> { accepted }, class_name: "UserFollowRequest", foreign_key: "requested_user_id"

  def friends
    User.where(id: accepted_sent_requests.select(:requested_user_id))
        .or(User.where(id: accepted_received_requests.select(:requesting_user_id)))
  end

  def friend?(user)
    friends.exists?(user.id)
  end

  def friendship_status(user)
    request = UserFollowRequest.where(requesting_user: self, requested_user: user)
                               .or(UserFollowRequest.where(requesting_user: user, requested_user: self))
                               .first
    request&.follow_request_status || "none"
  end

  after_create :create_default_profile

  private

  def create_default_profile
    create_profile(display_name: email.split('@').first)
  end
end

