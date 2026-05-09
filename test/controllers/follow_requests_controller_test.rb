require "test_helper"

class FollowRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @requested_user = users(:three)
    @received_request = user_follow_requests(:two)
    @sent_request = user_follow_requests(:one)
  end

  test "should get index" do
    sign_in @user

    get follow_requests_url
    assert_response :success
  end

  test "should destroy sent follow request" do
    sign_in @user

    assert_difference("UserFollowRequest.count", -1) do
      delete follow_request_url(@sent_request)
    end

    assert_redirected_to follow_requests_url
  end

  test "requested user should accept follow request" do
    sign_in users(:three)

    patch accept_follow_request_url(@received_request)

    assert_redirected_to received_follow_requests_url
    assert_equal "accepted", @received_request.reload.follow_request_status
  end

  test "requested user should reject follow request" do
    sign_in users(:three)

    patch reject_follow_request_url(@received_request)

    assert_redirected_to received_follow_requests_url
    assert_equal "rejected", @received_request.reload.follow_request_status
  end

  test "should get received" do
    sign_in users(:three)

    get received_follow_requests_url
    assert_response :success
  end

  test "should get sent" do
    sign_in @user

    get sent_follow_requests_url
    assert_response :success
  end

  test "should create follow request" do
    sign_in users(:two)

    assert_difference("UserFollowRequest.count", 1) do
      post user_follow_requests_url(@requested_user)
    end

    assert_redirected_to user_url(@requested_user)
  end

  test "non-participant cannot destroy another user's follow request" do
    # follow_requests(:two): requesting_user one, requested_user three
    # users(:two) is not a participant
    sign_in users(:two)

    assert_no_difference("UserFollowRequest.count") do
      delete follow_request_url(@received_request)
    end

    assert_redirected_to follow_requests_url
    assert_equal "Not authorized.", flash[:alert]
  end

  test "requesting user cannot accept their own sent request" do
    # follow_requests(:two): requesting_user one, requested_user three
    # only requested_user (three) may accept
    sign_in @user

    patch accept_follow_request_url(@received_request)

    assert_redirected_to follow_requests_url
    assert_equal "Not authorized.", flash[:alert]
    assert_equal "pending", @received_request.reload.follow_request_status
  end

  test "requesting user cannot reject their own sent request" do
    sign_in @user

    patch reject_follow_request_url(@received_request)

    assert_redirected_to follow_requests_url
    assert_equal "Not authorized.", flash[:alert]
    assert_equal "pending", @received_request.reload.follow_request_status
  end
end
