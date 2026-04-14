class User < ApplicationRecord
  attr_accessor :oauth_display_name

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

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

  after_commit :create_default_profile, on: :create

  def self.from_google_oauth(auth)
    email = auth.info.email&.downcase
    verified_email = auth.info.email_verified || auth.extra&.raw_info&.email_verified || auth.extra&.raw_info&.verified_email

    raise ArgumentError, "Google account must provide verified email" unless email.present? && verified_email

    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    user = find_by(email: email)
    if user
      user.update!(provider: auth.provider, uid: auth.uid)
      user
    else
      create!(
        email: email,
        password: Devise.friendly_token.first(32),
        provider: auth.provider,
        uid: auth.uid,
        oauth_display_name: auth.info.name
      )
    end
  end

  private

  def create_default_profile
    create_profile(display_name: oauth_display_name.presence || email.split("@").first)
  end
end
