require "test_helper"

class UserFollowRequestTest < ActiveSupport::TestCase
  test "cannot follow self" do
    request = UserFollowRequest.new(requesting_user: users(:one), requested_user: users(:one))
    assert_not request.valid?
    assert_includes request.errors[:requested_user_id], "cannot follow yourself"
  end

  test "cannot duplicate same direction" do
    # user_follow_requests(:one): one -> two already exists
    duplicate = UserFollowRequest.new(requesting_user: users(:one), requested_user: users(:two))
    assert_not duplicate.valid?
  end

  test "default status is pending" do
    request = UserFollowRequest.new(requesting_user: users(:two), requested_user: users(:one))
    assert_equal "pending", request.follow_request_status
  end

  test "valid new request between users with no prior request" do
    # users(:two) -> users(:three): no existing request
    request = UserFollowRequest.new(requesting_user: users(:two), requested_user: users(:three))
    assert request.valid?
  end
end
