class UserFollowRequest < ApplicationRecord
  belongs_to :requesting_user
  belongs_to :requested_user
end
