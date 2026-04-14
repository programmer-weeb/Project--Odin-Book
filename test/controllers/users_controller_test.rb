require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
  end

  test "should get index" do
    sign_in @user

    get users_url
    assert_response :success
  end

  test "should get show" do
    sign_in @user

    get user_url(@other_user)
    assert_response :success
  end

  test "should get friends" do
    sign_in @user

    get friends_user_url(@user)
    assert_response :success
  end
end
