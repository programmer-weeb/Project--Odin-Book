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
end
