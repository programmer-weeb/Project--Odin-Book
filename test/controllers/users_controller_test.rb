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

  test "index page=2 returns success" do
    sign_in @user

    get users_url, params: { page: 2 }
    assert_response :success
  end

  test "show page=2 returns success" do
    sign_in @user

    get user_url(@other_user), params: { page: 2 }
    assert_response :success
  end

  test "index page 1 shows pagy navigation when many users exist" do
    sign_in @user
    20.times { |i| User.create!(email: "pagy_user#{i}@example.com", password: "password123") }

    get users_url
    assert_response :success
    assert_match(/class="pagy nav"/, response.body)
  end

  test "show page 1 shows pagy navigation when user has many posts" do
    sign_in @user
    21.times { |i| Post.create!(content: "Post #{i}", user: @other_user) }

    get user_url(@other_user)
    assert_response :success
    assert_match(/class="pagy nav"/, response.body)
  end
end
