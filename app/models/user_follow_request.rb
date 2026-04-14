class UserFollowRequest < ApplicationRecord
  belongs_to :requesting_user, class_name: "User"
  belongs_to :requested_user, class_name: "User"

  enum :follow_request_status, { pending: 0, accepted: 1, rejected: 2 }, default: :pending

  validates :requesting_user_id, uniqueness: { scope: :requested_user_id }
  validate :not_following_self

  private

  def not_following_self
    errors.add(:requested_user_id, "cannot follow yourself") if requesting_user_id == requested_user_id
  end
end

