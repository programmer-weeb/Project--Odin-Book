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

  test "broadcasts pending count to recipient on create" do
    sender = users(:two)
    recipient = users(:three)
    assert_turbo_stream_broadcasts [ recipient, :pending_requests ], count: 1 do
      UserFollowRequest.create!(requesting_user: sender, requested_user: recipient)
    end
  end

  test "broadcasts to recipient on accept" do
    fr = user_follow_requests(:two)
    recipient = fr.requested_user
    assert_turbo_stream_broadcasts [ recipient, :pending_requests ], count: 1 do
      fr.update!(follow_request_status: :accepted)
    end
  end
end
