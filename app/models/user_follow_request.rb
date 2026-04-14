class UserFollowRequest < ApplicationRecord
  belongs_to :requesting_user, class_name: "User"
  belongs_to :requested_user, class_name: "User"

  enum :follow_request_status, { pending: 0, accepted: 1, rejected: 2 }, default: :pending
end
