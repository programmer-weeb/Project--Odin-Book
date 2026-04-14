require "test_helper"

class FollowRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get follow_requests_index_url
    assert_response :success
  end

  test "should get destroy" do
    get follow_requests_destroy_url
    assert_response :success
  end

  test "should get accept" do
    get follow_requests_accept_url
    assert_response :success
  end

  test "should get reject" do
    get follow_requests_reject_url
    assert_response :success
  end

  test "should get received" do
    get follow_requests_received_url
    assert_response :success
  end

  test "should get sent" do
    get follow_requests_sent_url
    assert_response :success
  end

  test "should get create" do
    get follow_requests_create_url
    assert_response :success
  end
end
